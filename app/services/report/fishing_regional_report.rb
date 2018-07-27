class Report::FishingRegionalReport < Report
  def title
    "Fishing Regional Report"
  end

  def results
    results =
      registrations.map do |registration|
        assign_result(registration)
      end

    results.sort_by { |r| [r.data_elements[1], r.data_elements[0]] }
  end

  def headings
    [
      "Name", "PLN", "Official No", "Registered Length", "Overall Length",
      "Depth", "Breadth", "Gross Tonnage", "Net Tonnage", "Power (kW)",
      "Construction", "Year Built", "Owner(s) Name, Address & Shareholding",
      "Registration Status", "Transaction Type", "Date of Transaction"
    ]
  end

  private

  def registrations
    Registration
      .fishing_vessels
      .includes(:submissions)
      .where("created_at >= ?", @date_start)
      .where("created_at <= ?", @date_end)
  end

  def load_vessel(registration)
    Decorators::Vessel.new(registration.vessel)
  end

  def transaction_type(registration)
    return "" if registration.submissions.empty?
    DeprecableTask.new(registration.submissions.first.task).description
  end

  def assign_result(registration) # rubocop:disable Metrics/MethodLength
    vessel = load_vessel(registration)
    Result.new(
      [
        vessel.name,
        vessel.pln,
        vessel.reg_no,
        vessel.register_length,
        vessel.length_overall,
        vessel.depth,
        vessel.breadth,
        vessel.gross_tonnage,
        vessel.net_tonnage,
        Engine.total_mcep_for(registration),
        vessel.hull_construction_material,
        vessel.year_of_build,
        registration.owner_name_address_shareholding,
        (registration.closed_at? ? "Closed" : "Registered"),
        transaction_type(registration),
        registration.created_at,
      ])
  end
end
