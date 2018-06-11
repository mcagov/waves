module Register
  class Vessel < ApplicationRecord # rubocop:disable Metrics/ClassLength
    include PgSearch
    include Register::TerminationStateMachine

    multisearchable against:
      [
        :reg_no,
        :name,
        :mmsi_number,
        :radio_call_sign,
        :imo_number,
        :hin,
        :pln,
        :owner_info
      ]

    def owner_info
      owners.map(&:inline_name_and_address).join("; ")
    end

    validates :part, presence: true
    validates :reg_no, presence: true

    has_one :agent, as: :parent, class_name: "Register::Agent"
    has_many :beneficial_owners, as: :parent, class_name: "BeneficialOwner"
    has_many :directed_bys, as: :parent, class_name: "DirectedBy"
    has_many :managed_bys, as: :parent, class_name: "ManagedBy"
    has_many :customers, as: :parent
    has_one :representative, as: :parent, class_name: "Register::Representative"
    has_many :owners,
             -> { order("updated_at asc") },
             class_name: "Register::Owner",
             as: :parent

    has_many :managers,
             -> { order(:name) },
             class_name: "Manager",
             as: :parent

    has_many :shareholder_groups, dependent: :destroy

    belongs_to :current_registration, class_name: "Registration"

    has_many :registrations, -> { order("created_at desc") }
    has_one :first_registration,
            -> { order("registered_at asc").limit(1) },
            class_name: "Registration"

    has_many :correspondences, as: :noteable

    has_many :notifications, as: :notifiable

    has_one :code_certificate_reminder,
            -> { order("created_at desc").limit(1) },
            as: :notifiable,
            class_name: "Notification::CodeCertificateReminder"

    has_one :renewal_reminder,
            -> { order("created_at desc").limit(1) },
            as: :notifiable,
            class_name: "Notification::RenewalReminder"

    has_one :safety_certificate_reminder,
            -> { order("created_at desc").limit(1) },
            as: :notifiable,
            class_name: "Notification::SafetyCertificateReminder"

    has_many :code_certificates,
             -> { where("entity_type = 'code_certificate'") },
             class_name: "Document",
             as: :noteable

    has_many :fishing_vessel_safety_certificates,
             -> { where("entity_type = 'fishing_vessel_safety_certificate'") },
             class_name: "Document",
             as: :noteable

    has_many :documents,
             -> { order("created_at desc") },
             as: :noteable

    has_many :notes,
             -> { where("type is null").order("created_at desc") },
             as: :noteable

    has_many :section_notices,
             (lambda do
                where("type = 'Register::SectionNotice'")
                  .order("created_at desc")
              end),
             as: :noteable

    has_many :submissions,
             -> { order("created_at desc") },
             foreign_key: :registered_vessel_id
    has_one :latest_completed_submission,
            (lambda do
              where("completed_at is not null")
              .order("created_at desc").limit(1)
            end),
            foreign_key: :registered_vessel_id,
            class_name: "Submission"

    has_many :engines, as: :parent

    has_many :charterers, as: :parent
    has_many :charter_parties,
             -> { order("name") },
             through: :charterers

    has_many :mortgages,
             -> { order("priority_code asc") },
             as: :parent

    has_many :mortgagees, through: :mortgages

    has_many :csr_forms, -> { order("issue_number desc") }

    scope :in_part, ->(part) { where(part: part.to_sym) if part }
    scope :frozen, -> { where.not(frozen_at: nil) }
    scope :not_frozen, -> { where(frozen_at: nil) }

    delegate :registered_at, to: :current_registration, allow_nil: true
    delegate :registered_until, to: :current_registration, allow_nil: true

    before_validation :build_reg_no, on: :create

    def correspondent
      owners.where(correspondent: true).first ||
        charter_parties.where(correspondent: true).first ||
        owners.first
    end

    def build_reg_no
      return if reg_no.present?
      self.reg_no = SequenceNumber::Generator.reg_no!(part)
    end

    def to_s
      name.upcase
    end

    def notification_list
      Builders::NotificationListBuilder.for_registered_vessel(self)
    end

    def registration_status
      RegistrationStatus.new(self)
    end

    def registry_info # rubocop:disable Metrics/MethodLength
      {
        vessel_info: attributes,
        owners: owners.map(&:attributes),
        agent: (agent || Register::Agent.new).attributes,
        shareholder_groups: shareholder_groups_info,
        engines: engines.map(&:attributes),
        managers: managers_info,
        mortgages: mortgages_info,
        charterers: charterers_info,
        beneficial_owners: beneficial_owners.map(&:attributes),
        directed_bys: directed_bys.map(&:attributes),
        managed_bys: managed_bys.map(&:attributes),
        representative: representative_info,
      }
    end

    def prints_registration_certificate?
      registration_status == :registered
    end

    def prints_transcript?
      registration_status != :pending
    end

    def pln
      "#{port_code} #{port_no}"
    end

    def ec_no
      return unless reg_no && Policies::Definitions.fishing_vessel?(self)
      "GBR000#{reg_no}"
    end

    private

    def shareholder_groups_info
      shareholder_groups.map do |sharedholder_group|
        {
          owners: sharedholder_group.owners.map(&:details),
          group_member_keys: sharedholder_group.group_member_keys,
          shares_held: sharedholder_group.shares_held,
        }
      end
    end

    def managers_info
      managers.map do |manager|
        manager.attributes.merge(
          safety_management: manager.safety_management.try(:attributes))
      end
    end

    def mortgages_info
      mortgages.map do |mortgage|
        mortgage.attributes.merge(
          mortgagors: mortgage.mortgagors.map(&:attributes),
          mortgagees: mortgage.mortgagees.map(&:attributes))
      end
    end

    def charterers_info
      charterers.map do |charterer|
        charterer.attributes.merge(
          charter_parties: charterer.charter_parties.map(&:attributes))
      end
    end

    def representative_info
      (representative || Register::Representative.new).attributes
    end
  end
end
