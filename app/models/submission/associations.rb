# rubocop:disable all
module Submission::Associations
  class << self
    def included(base)
      notes_associations(base)
      declaration_associations(base)
      ownership_associations(base)
      misc_associations(base)
      notification_associations(base)
      payment_associations(base)
      registration_associations(base)
      user_associations(base)
    end

    def notes_associations(base)
      base.has_many :correspondences, as: :noteable
      base.has_many :documents, as: :noteable
      base.has_many :notes,
                    -> { where("type is null").order("created_at desc") },
                    as: :noteable
    end

    def declaration_associations(base)
      base.has_many :declarations, -> { order("created_at asc") }
      base.has_many :declaration_groups, class_name: "Declaration::Group"
    end

    def misc_associations(base)
      base.has_many :carving_and_markings, -> { order("created_at asc") }
      base.has_many :engines, as: :parent
      base.has_many :mortgages, -> { order("priority_code asc") }, as: :parent
      base.has_many :charterers, -> { order("created_at asc") }, as: :parent
      base.has_many :charter_parties, through: :charterers
      base.has_one  :csr_form
      base.has_one :name_approval, class_name: "Submission::NameApproval"
      base.has_many :print_jobs
      base.has_many :tasks, class_name: "Submission::Task"
      base.has_many :work_logs, through: :tasks
    end

    def ownership_associations(base)
      base.belongs_to :correspondent, class_name: "Customer", required: false
      base.belongs_to :managing_owner, class_name: "Customer", required: false

      base.has_many :beneficial_owners,
                    -> { order(:name) },
                    class_name: "BeneficialOwner",
                    as: :parent

      base.has_many :directed_bys,
                    -> { order(:name) },
                    class_name: "DirectedBy",
                    as: :parent

      base.has_many :managed_bys,
                    -> { order(:name) },
                    class_name: "ManagedBy",
                    as: :parent

      base.has_many :managers,
                    -> { order(:name) },
                    class_name: "Manager",
                    as: :parent
    end

    def notification_associations(base)
      base.has_many :notifications, as: :notifiable

      base.has_one :cancellation, -> { order("created_at desc").limit(1) },
                   as: :notifiable,
                   class_name: "Notification::Cancellation"

      base.has_one :referral, -> { order("created_at desc").limit(1) },
                   as: :notifiable,
                   class_name: "Notification::Referral"

      base.has_one :application_receipt,
                   -> { order("created_at desc").limit(1) },
                   as: :notifiable,
                   class_name: "Notification::ApplicationReceipt"

      base.has_one :carving_and_marking_reminder,
                   -> { order("created_at desc").limit(1) },
                   as: :notifiable,
                   class_name: "Notification::CarvingAndMarkingReminder"
    end

    def payment_associations(base)
      base.has_many :payments
    end

    def registration_associations(base)
      base.belongs_to :registration

      base.belongs_to :registered_vessel,
                      lambda { |submission|
                        where("vessels.part = ?", submission.part)
                      },
                      foreign_key: :registered_vessel_id,
                      class_name: "Register::Vessel"
    end

    def user_associations(base)
      base.belongs_to :claimant, class_name: "User", required: false
      base.scope :assigned_to, -> (claimant) { where(claimant: claimant) }
    end
  end

  def task
    application_type
  end

  def task=(val)
    self.application_type = val
  end

  def owners
    declarations.map(&:owner)
  end

  def vessel
    Submission::Vessel.new(symbolized_changeset[:vessel_info] || {})
  end

  def agent
    Submission::Agent.new(symbolized_changeset[:agent] || {})
  end

  def representative
    Submission::Representative.new(symbolized_changeset[:representative] || {})
  end

  def closure
    Submission::Closure.new(symbolized_changeset[:closure] || {})
  end

  def vessel=(vessel_params)
    self.changeset ||= {}
    changeset[:vessel_info] = vessel_params
  end

  def agent=(agent_params)
    self.changeset ||= {}
    changeset[:agent] = agent_params
  end

  def representative=(representative_params)
    self.changeset ||= {}
    changeset[:representative] = representative_params
  end

  def delivery_address
    Submission::DeliveryAddress.new(
      symbolized_changeset[:delivery_address] || {})
  end

  def delivery_address=(delivery_address_params)
    changeset[:delivery_address] = delivery_address_params
  end

  private

  def finance_payment
    payment.remittance if payment && source.to_sym == :manual_entry
  end
end
# rubocop:enable all
