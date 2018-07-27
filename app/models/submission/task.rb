class Submission::Task < ApplicationRecord
  belongs_to :service
  delegate :to_sym, to: :service

  belongs_to :submission
  delegate :part, to: :submission
  delegate :received_at, to: :submission

  belongs_to :claimant, required: false, class_name: "User"

  has_many :work_logs, foreign_key: :submission_task_id

  validate :service_level_validations
  enum service_level: ServiceLevel::SERVICE_LEVEL_TYPES.map(&:last)

  protokoll :submission_ref_counter, scope_by: :submission_id, pattern: "#"

  before_save :set_defaults

  scope :in_part, (lambda do |part|
    joins(:submission).where("submissions.part = ?", part) if part
  end)

  scope :active, -> { where.not(state: [:completed]) }
  scope :claimed_by, -> (claimant) { where(claimant: claimant) }

  include ActiveModel::Transitions

  state_machine auto_scopes: true do
    state :initialising
    state :unclaimed
    state :claimed
    state :referred
    state :completed
    state :cancelled

    event :confirm do
      transitions to: :unclaimed, from: :initialising,
                  guard: :initialising?
    end

    event :claim do
      transitions to: :claimed,
                  from: [:unclaimed, :cancelled],
                  on_transition: :add_claimant
    end

    event :refer do
      transitions to: :referred, from: :claimed,
                  on_transition: :remove_claimant
    end

    event :unclaim do
      transitions to: :unclaimed, from: :claimed,
                  on_transition: :remove_claimant
    end

    event :complete, timestamp: :completed_at do
      transitions to: :completed, from: :claimed,
                  on_transition: :process_task,
                  guard: :approvable?
    end

    event :cancel do
      transitions to: :cancelled, from: :claimed,
                  on_transition: [
                    :remove_claimant,
                    :cancel_name_approval,
                    :remove_pending_vessel]
    end

    event :unrefer do
      transitions to: :unclaimed, from: :referred
    end
  end

  def ref_no
    "#{submission.ref_no}/#{submission_ref_counter}"
  end

  def process_task
  end

  def actionable?
    true
  end

  def referrable?
    true
  end

  def approvable?
    true
  end

  def display_registry_info?
    true
  end

  def display_changeset?
    true
  end

  private

  def set_defaults
    self.start_date ||= submission.received_at || Date.current
    self.price = service.price_for(part, service_level.to_sym)
    self.target_date = TargetDate.for_task(self) unless initialising?
  end

  def service_level_validations
    if service_level.blank?
      errors.add(:service_level, "is required")
    elsif service_level.to_sym == :premium && !service.supports_premium?(part)
      errors.add(:service_level, "is not allowed")
    end
  end

  def add_claimant(user)
    update_attribute(:claimant, user)
  end

  def remove_claimant
    update_attribute(:claimant, nil)
  end

  def cancel_name_approval
  end

  def remove_pending_vessel
  end
end
