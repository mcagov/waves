class Service < ApplicationRecord
  scope :in_part, ->(part) { where.not(part.to_sym => nil) }

  def to_s
    name
  end

  def price_for(part, service_level)
    case service_level.to_sym
    when :standard
      standard_price(part)
    when :premium
      premium_price(part)
    when :subsequent
      subsequent_price(part)
    end
  end

  def supports_premium?(part)
    premium_supplement(part)
  end

  private

  def price(part)
    (send(part) || {}).symbolize_keys
  end

  def pence(amount)
    return unless amount
    amount * 100
  end

  def standard_price(part)
    pence(price(part)[:standard])
  end

  def premium_price(part)
    premium_supplement(part) + standard_price(part) if premium_supplement(part)
  end

  def premium_supplement(part)
    pence(price(part)[:premium])
  end

  def subsequent_price(part)
    pence(price(part)[:subsequent])
  end
end
