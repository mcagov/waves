class Submission::Vessel
  attr_accessor(
    :name,
    :hin,
    :make_and_model,
    :length_in_meters,
    :number_of_hulls,
    :mmsi_number,
    :radio_call_sign,
    :alt_name_1,
    :alt_name_2,
    :alt_name_3,
    :length_in_meters,
    :vessel_type,
    :vessel_type_other
  )

  def initialize(params = {})
    params.reject! { |param| !respond_to?(param) }
    params.each { |key, value| instance_variable_set("@#{key}", value) }
  end

  def type_of_vessel
    if vessel_type_other.present?
      vessel_type_other
    else
      vessel_type
    end
  end

  def to_s
    name
  end
end
