class Payment < ApplicationRecord
  belongs_to :submission, touch: true, required: false
  belongs_to :remittance, polymorphic: true
end
