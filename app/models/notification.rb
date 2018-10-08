class Notification < ApplicationRecord
  attr_accessor :actionable_at

  belongs_to :notifiable, polymorphic: true
  belongs_to :actioned_by, class_name: "User"
  belongs_to :approved_by, class_name: "User"

  before_save :process!

  include ActiveModel::Transitions

  state_machine auto_scopes: true do
    state :ready_for_delivery
    state :pending_approval
    state :approved
    state :delivered

    event :require_approval do
      transitions to: :pending_approval, from: [:ready_for_delivery],
                  guard: :system_generated?
    end

    event :deliver, timestamp: true do
      transitions to: :delivered, from: [:ready_for_delivery, :approved],
                  on_transition: :send_email,
                  guard: :deliverable?
    end

    event :approve, timestamp: true do
      transitions to: :approved, from: [:pending_approval],
                  on_transition: :add_approved_by
    end
  end

  attr_accessor :recipient

  def send_email
    NotificationMailer.delay.send(
      email_template, default_params, *additional_params)
  end

  def email_template
    :test_email
  end

  def additional_params; end

  def email_subject
    self.class.to_s.demodulize
  end

  def process!
    require_approval! if can_require_approval?
    deliver! if can_deliver?
  end

  def deliverable?
    recipient_name.present? && recipient_email.present?
  end

  def system_generated?
    actioned_by.blank?
  end

  def add_approved_by(user)
    update_attribute(:approved_by_id, user.id) && process!
  end

  private

  def default_params
    {
      subject: email_subject,
      to: recipient_email,
      name: recipient_name,
      department: Department.new(
        notifiable.part,
        Policies::Definitions.registration_type(notifiable)),
    }
  end
end
