class Engine < ApplicationRecord
  belongs_to :parent, polymorphic: true

  ENGINE_TYPES = %w(Inboard Outboard).freeze

  DERATINGS = [
    "None",
    "Fuel Rack Limited",
    "Fuel Pump Changed",
    "Engine Governor Adjusted",
    "Turbo Charger Removed",
    "Electronic Governor Modified",
    "Other agreed method",
  ].freeze

  def make_and_model
    [make, model].join(" ")
  end

  def total_mcep
    (quantity.to_i * mcep_after_derating.to_f)
  end

  class << self
    def total_mcep_for(submission)
      result = submission.engines.sum(&:total_mcep)
      result == result.to_i ? result : result.round(2)
    end
  end
end
