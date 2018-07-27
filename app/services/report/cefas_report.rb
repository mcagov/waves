class Report::CefasReport < Report
  def title
    "Open Registrations"
  end

  def second_sheet_title
    "Closed Registrations"
  end

  def third_sheet_title
    "Changes to Registration Details"
  end

  def results
    build_results(
      scoped_submissions.where(application_type: :new_registration))
  end

  def second_sheet_results
    build_results(scoped_submissions.where(application_type: :closure))
  end

  def third_sheet_results
    build_results(
      scoped_submissions
      .where(
        [
          "application_type in (?, ?, ?, ?)",
          :renewal, :change_owner, :change_vessel, :change_address
        ]
      )
    )
  end

  def headings
    [
      "Country of registration", "CFR / EC no.", "IMO number", "Event type",
      "Date of event", "Reason for closure", "Company number", "PLN",
      "Name of Vessel", "Place of registration", "IRCS / RCS", "MMSI",
      "Tonnage GT", "Other tonnage", "Power of Main engine", "Derated method",
      "Make of engine", "Model of engine", "Hull construction material",
      "Date of entry into service", "Year of construction",
      "Name and address of owners"
    ]
  end

  private

  def scoped_submissions
    Submission
      .includes(:declarations, :engines, :registration)
      .fishing_vessels
      .completed
      .where("completed_at >= ?", @date_start)
      .where("completed_at <= ?", @date_end)
  end

  def load_vessel(submission)
    Decorators::Vessel.new(submission.vessel)
  end

  def build_results(submissions)
    submissions.map do |submission|
      assign_result(submission)
    end
  end

  # rubocop:disable all
  def assign_result(submission)
    vessel = submission.vessel
    registration = submission.registration
    engine = submission.engines.first || Engine.new

    Result.new(
      [
        country_of_registration(registration),
        submission.vessel_ec_no,
        vessel.imo_number,
        event_type(submission),
        submission.completed_at,
        closure_reason(registration),
        submission.vessel_reg_no,
        vessel.pln,
        vessel.name,
        vessel.port_name,
        vessel.classification_society,
        vessel.mmsi_number,
        vessel.gross_tonnage,
        vessel.net_tonnage, # 'Other tonnage'
        engine.total_mcep,
        engine.derating,
        engine.make,
        engine.model,
        vessel.hull_construction_material,
        vessel.entry_into_service_at,
        vessel.year_of_build,
        submission.owners.map(&:inline_name_and_address).join("; "),
      ])
  end
  # rubocop:enable all

  def country_of_registration(registration)
    return "GBR" unless registration.try(:closed_at?)
  end

  def closure_reason(registration)
    return registration.description if registration.try(:closed_at?)
  end

  def event_type(submission)
    case submission.task.to_sym
    when :new_registration
      "Open"
    when :closure
      "Closed"
    else
      "Change to details"
    end
  end
end
