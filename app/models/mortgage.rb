class Mortgage < ApplicationRecord
  belongs_to :parent, polymorphic: true
  has_many :mortgagees, inverse_of: :mortgage, as: :parent, dependent: :destroy
  has_many :mortgagors, inverse_of: :mortgage, as: :parent, dependent: :destroy

  # rubocop:disable Style/AlignHash
  accepts_nested_attributes_for :mortgagees, allow_destroy: true,
    reject_if: proc { |attributes| attributes["name"].blank? }

  accepts_nested_attributes_for :mortgagors, allow_destroy: true

  scope :not_discharged, -> { where(discharged_at: nil) }

  delegate :part, to: :parent

  def vessel
    parent if parent.is_a?(Register::Vessel)
  end

  class << self
    def types_for(submission)
      if DeprecableTask.new(submission.task).new_registration?
        %w(Intent)
      else
        ["Intent", "Account Current", "Principle Sum"]
      end
    end
  end

  def register!(datetime_to_register)
    case mortgage_type
    when "Intent"
      update_attribute(:registered_at, nil) if registered_at?
    else
      unless registered_at.present?
        update_attribute(:registered_at, datetime_to_register || Time.zone.now)
      end
    end

    reload
  end
end
