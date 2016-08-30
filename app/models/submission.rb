class Submission < ApplicationRecord
  include SubmissionTransitions

  belongs_to :delivery_address, class_name: "Address", required: false
  belongs_to :claimant, class_name: "User", required: false

  has_one :payment
  has_many :notifications
  has_one :registration
  has_one :registered_vessel, through: :registration

  default_scope { includes(:payment).order('target_date asc').where.not(state: 'completed') }
  scope :assigned_to, lambda {|claimant| where(claimant: claimant)}

  validates :part, presence: true

  validates :ref_no, presence: true
  before_validation :set_ref_no

  def set_ref_no
    self.ref_no ||= RefNo.generate("00")
  end

  def process_application; end

  def paid?
    payment.present?
  end

  def vessel
    @vessel ||= Submission::Vessel.new(user_input[:vessel_info])
  end

  def owners
    @owners ||=
      (user_input[:owners] || []).map do |owner_params|
        Submission::Owner.new(owner_params)
      end
  end

  def declarations
    user_input[:declarations] || []
  end

  def declared_by?(email)
    declarations.include?(email)
  end

  def applicant
    owners.first if owners
  end

  def source
    'Online'
  end

  protected

  def user_input
    @user_input ||=
      changeset.blank? ? {} : changeset.deep_symbolize_keys!
  end
end
