class Submission::Vessel < WavesUtilities::Vessel
  def search_attributes
    [
      :name,
      :mmsi_number,
      :radio_call_sign,
      :imo_number,
      :hin,
      :pln,
    ].map { |attr| send(attr) }.join(" ")
  end
end
