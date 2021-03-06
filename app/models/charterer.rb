class Charterer < ApplicationRecord
  belongs_to :parent, polymorphic: true

  has_many :charter_parties,
           -> { order(:name) },
           as: :parent,
           class_name: "CharterParty",
           dependent: :destroy

  # rubocop:disable Style/AlignHash
  accepts_nested_attributes_for :charter_parties, allow_destroy: true,
    reject_if: proc { |attributes| attributes["name"].blank? }

  def charter_period
    [start_date, end_date].join(" - ")
  end
end
