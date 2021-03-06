class Register::Fleet
  attr_reader :key

  def initialize(key)
    @key = key.to_sym
  end

  def to_s
    FLEETS.find { |f| f[1] == @key }[0]
  end

  # rubocop:disable all
  FLEETS = [
    ["Part I Merchant vessels under 100gt (R)", :p1_merchant_under_100gt_registered],
    ["Part I Merchant vessels under 100gt (F)", :p1_merchant_under_100gt_frozen],
    ["Total Part 1 Merchant vessels under 100gt (F)", :p1_merchant_under_100gt],

    ["Part I Merchant vessels 100 - 499gt (R)", :p1_merchant_100_to_499gt_registered],
    ["Part I Merchant vessels 100 - 499gt (F)", :p1_merchant_100_to_499gt_frozen],
    ["Total Part 1 Merchant vessels 100 - 499gt  (F)", :p1_merchant_100_to_499gt],

    ["Part I Merchant vessels 500gt and over (R)", :p1_merchant_over_500gt_registered],
    ["Part I Merchant vessels 500gt and over (F)", :p1_merchant_over_500gt_frozen],
    ["Total Part 1 Merchant vessels 500gt and over", :p1_merchant_over_500gt],

    ["Total Part 1 Merchant vessels", :p1_merchant],
    ["Total Part 1 Pleasure vessels", :p1_pleasure],
    ["Part I Grand Total (Merchant and Pleasure)", :p1],

    ["Part II Fishing Vessels (<15m) (overall length)", :p2_under_15m],
    ["Part II Fishing Vessels (15-24m) (overall length)", :p2_between_15_24m],
    ["Part II Fishing Vessels (>24m) (overall length)", :p2_over_24m],
    ["Total Part II Fishing Vessels", :p2],

    ["Total Part III Small Ships", :p3],

    ["Part IV Bareboat Charter Merchant (R)", :p4_merchant_registered],
    ["Part IV Bareboat Charter Merchant (F)", :p4_merchant_frozen],
    ["Part IV Bareboat Charter Fishing (R)", :p4_fishing_registered],
    ["Part IV Bareboat Charter Fishing (F)", :p4_fishing_frozen],
    ["Part IV Bareboat Charter Pleasure (R)", :p4_pleasure_registered],
    ["Part IV Bareboat Charter Pleasure (F)", :p4_pleasure_frozen],
    ["Total Part IV Bareboat Charter", :p4],

    ["All Vessels on the Registry (R)", :registered],
    ["All Vessels on the Registry (F)", :frozen]].freeze

  def report_query_filter(query)
    query = query.in_part(:part_1) if @key =~ /^p1.*/
    query = query.in_part(:part_2) if @key =~ /^p2.*/
    query = query.in_part(:part_3) if @key =~ /^p3.*/
    query = query.in_part(:part_4) if @key =~ /^p4.*/

    query = query.where(p1_merchant) if @key =~ /^p1_merchant.*/
    query = query.where(p1_pleasure) if @key =~ /^p1_pleasure.*/

    query = query.where(p4_merchant) if @key =~ /^p4_merchant.*/
    query = query.where(p4_fishing) if @key =~ /^p4_fishing.*/
    query = query.where(p4_pleasure) if @key =~ /^p4_pleasure.*/

    query = query.where(under_100gt) if @key =~ /.*under_100gt.*/
    query = query.where(from_100_to_499gt) if @key =~ /.*100_to_499gt.*/
    query = query.where(over_500gt) if @key =~ /.*over_500gt.*/

    query = query.where(under_15m) if @key =~ /.*under_15m.*/
    query = query.where(from_15_to_24m) if @key =~ /.*between_15_24m.*/
    query = query.where(over_24m) if @key =~ /.*over_24m.*/

    query = query.not_frozen if @key =~ /.*registered/
    query = query.frozen if @key =~ /.*frozen/

    query
  end
  # rubocop:enable all

  def p1_merchant
    "registration_type = 'commercial'"
  end

  def p1_pleasure
    "registration_type = 'pleasure'"
  end

  def p4_merchant
    "registration_type = 'commercial'"
  end

  def p4_fishing
    "registration_type = 'fishing'"
  end

  def p4_pleasure
    "registration_type = 'pleasure'"
  end

  def under_100gt
    "COALESCE(gross_tonnage, 0) < 100"
  end

  def from_100_to_499gt
    "COALESCE(gross_tonnage, 0) BETWEEN 100 AND 499.999"
  end

  def over_500gt
    "COALESCE(gross_tonnage, 0) >= 500"
  end

  def under_15m
    "COALESCE(length_overall, 0) < 15"
  end

  def from_15_to_24m
    "COALESCE(length_overall, 0) BETWEEN 15 AND 23.999"
  end

  def over_24m
    "COALESCE(length_overall, 0) > 24"
  end
end
