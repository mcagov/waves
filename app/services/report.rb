class Report
  class << self
    def build(template, filters = {})
      klass = "Report::#{template.camelize}"
      klass.constantize.new(filters)
    end
  end

  def initialize(filters = {})
    @filters = filters.to_h.deep_symbolize_keys
    @part = filters[:part]
    @date_start = parse_date_start
    @date_end = parse_date_end
    @task = filters[:task] || "all_tasks"
    @page = filters[:page]
    @per_page = filters[:per_page]
    @document_type = filters[:document_type]
  end

  attr_accessor :pagination_collection

  def paginate(scoped_query)
    scoped_query.paginate(page: @page, per_page: @per_page)
  end

  Result = Struct.new(:data_elements, :sub_report_filters)

  RenderAsRegistrationStatus = Struct.new(:registration_status) do
    def to_s
      registration_status
    end
  end

  RenderAsLinkToVessel = Struct.new(:vessel, :attribute) do
    def to_s
      vessel.to_s
    end
  end

  RenderAsLinkToSubmission = Struct.new(:submission) do
    def to_s
      submission.ref_no
    end
  end

  RenderAsDownloadLink = Struct.new(:report_key) do
    def to_s
      ""
    end
  end

  RenderAsCurrency = Struct.new(:amount) do
    def to_s
      amount.to_s
    end
  end

  def filter_fields
    []
  end

  def sub_report
  end

  def headings
    []
  end

  def results
    []
  end

  def date_range_label
    "Date Range"
  end

  def first_sheet_title
    title
  end

  def second_sheet_title; end

  def third_sheet_title; end

  def fourth_sheet_title; end

  def links_to_export_or_print?
    true
  end

  def xls_title(prefix = nil)
    t = prefix || title
    t += ": #{@date_start}-#{@date_end}" if @date_start
    t
  end

  protected

  def filter_by_part(scoped_query)
    @part.present? ? scoped_query.in_part(@part) : scoped_query
  end

  def filter_by_received_at(scoped_query)
    if @date_start.present?
      scoped_query = scoped_query.where("received_at >= ?", @date_start)
    end

    if @date_end.present?
      scoped_query = scoped_query.where("received_at <= ?", @date_end)
    end

    scoped_query
  end

  def filter_by_registered_until(scoped_query)
    if @date_start.present?
      scoped_query =
        scoped_query.where("registrations.registered_until >= ?", @date_start)
    end

    if @date_end.present?
      scoped_query =
        scoped_query.where("registrations.registered_until <= ?", @date_end)
    end

    scoped_query
  end

  def filter_by_note_expires_at(scoped_query)
    if @date_start.present?
      scoped_query = scoped_query.where("notes.expires_at >= ?", @date_start)
    end

    if @date_end.present?
      scoped_query = scoped_query.where("notes.expires_at <= ?", @date_end)
    end

    scoped_query
  end

  def filter_by_document_type(scoped_query)
    if @document_type.present?
      scoped_query.where("notes.entity_type = ?", @document_type)
    else
      scoped_query
    end
  end

  def filter_by_task(scoped_query)
    if @task.present? && @task != "all_tasks"
      scoped_query.where("application_type = ?", @task.to_s)
    else
      scoped_query
    end
  end

  private

  def parse_date_start
    if @filters[:date_start].present?
      @filters[:date_start].to_date.at_beginning_of_day
    end
  end

  def parse_date_end
    @filters[:date_end].to_date.at_end_of_day if @filters[:date_end].present?
  end
end
