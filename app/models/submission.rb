class Submission < ApplicationRecord
  include Submission::Associations
  include Submission::StateMachine
  include Submission::Reporting

  include PgSearch
  multisearchable against:
    [
      :ref_no,
      :vessel_reg_no,
      :vessel_search_attributes,
      :owner_search_attributes,
      :finance_payment_attributes,
    ]

  validates :registered_vessel_id, uniqueness: true, if: :vessel_uniqueness?
  validates :part, presence: true
  validates :source, presence: true
  validates :task, presence: true

  validates :task,
            inclusion: {
              in: DeprecableTask.validation_helper_task_type_list,
              message: "must be selected" }

  validate :ref_no
  validate :registered_vessel_exists

  before_update :build_defaults, if: :registered_vessel_id_changed?

  scope :in_part, ->(part) { where(part: part.to_sym) if part }
  scope :active, -> { where.not(state: [:completed]) }
  scope :in_progress, -> { where(state: [:unassigned, :assigned, :referred]) }

  scope :referred_until_expired, lambda {
    where("referred_until < ?", Time.zone.today.at_end_of_day)
  }

  after_touch :check_current_state

  delegate :registration_status, to: :registered_vessel, allow_nil: true

  def vessel_uniqueness?
    return false if registered_vessel_id.blank?
    Submission
      .where(registered_vessel_id: registered_vessel.id)
      .where.not(id: id)
      .active.exists?
  end

  def check_current_state
    unassigned! if incomplete? && actionable?
  end

  def electronic_delivery?
    symbolized_changeset[:electronic_delivery]
  end

  def build_defaults
    Builders::SubmissionBuilder.build_defaults(self)
  end

  def init_processing_dates
    Builders::ProcessingDatesBuilder.create(self)
  end

  def actionable?
    Policies::Actions.actionable?(self)
  end

  def approvable?(_registration_start_date = nil)
    Policies::Actions.approvable?(self)
  end

  def editable?
    Policies::Actions.editable?(self)
  end

  def uneditable?
    !editable?
  end

  def process_application(approval_params = {})
    Submission::ApplicationProcessor.run(self, approval_params)
  end

  def job_type
    DeprecableTask.new(task).description
  end

  def symbolized_changeset
    changeset.blank? ? {} : changeset.deep_symbolize_keys!
  end

  def payment
    payments.first
  end

  def vessel_reg_no
    registered_vessel.reg_no if registered_vessel
  end

  def vessel_reg_no=(reg_no)
    self.registered_vessel =
      Register::Vessel.in_part(part).where(reg_no: reg_no).first
  end

  def vessel_ec_no
    registered_vessel.ec_no if registered_vessel
  end

  def vessel_name
    return vessel.name if vessel.name.present?
    return registered_vessel.name if registered_vessel
    if finance_payment && finance_payment.vessel_name.present?
      finance_payment.vessel_name
    else
      "UNKNOWN"
    end
  end

  protected

  def remove_claimant
    update_attribute(:claimant, nil)
  end

  def add_claimant(user)
    update_attribute(:claimant, user)
  end

  def cancel_name_approval
    return unless name_approval
    name_approval.update_attribute(:cancelled_at, Time.zone.now)
  end

  def remove_pending_vessel
    return unless registration_status == :pending
    registered_vessel.destroy
  end

  def registered_vessel_exists
    if Policies::Actions.registered_vessel_required?(self)
      unless registered_vessel
        errors.add(
          :vessel_reg_no,
          "was not found in the #{Activity.new(part)} Registry")
      end
    end
  end

  def vessel_search_attributes
    vessel.search_attributes
  end

  def owner_search_attributes
    return if declarations.empty?
    owners.compact.map(&:inline_name_and_address).join("; ")
  end

  def finance_payment_attributes
    return unless finance_payment
    finance_payment.searchable_attributes
  end
end
