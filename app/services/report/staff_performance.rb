class Report::StaffPerformance < Report
  def title
    "Staff Performance"
  end

  def sub_report
    :staff_performance_by_task
  end

  def filter_fields
    [:filter_part, :filter_user, :filter_date_range]
  end

  def headings
    [
      :task_type, :total_transactions,
      :within_service_standard, :service_standard_missed
    ]
  end

  def date_range_label
    "Task Actioned"
  end

  def user_label
    "Member of Staff"
  end

  def results
    services_results + totals
  end

  def services_results
    services.map do |service|
      staff_performance_logs = staff_performance_for(service)
      Result.new(
        [service.to_s,
         staff_performance_logs.count,
         staff_performance_logs.within_standard.count,
         RenderAsRed.new(staff_performance_logs.standard_missed.count)],
        service_id: service.id)
    end
  end

  def totals
    [Result.new(
      ["TOTAL",
       staff_performance_summary.count,
       staff_performance_summary.within_standard.count,
       staff_performance_summary.standard_missed.count])]
  end

  def services
    Service
      .in_part(@part)
      .order(:name)
      .includes(:staff_performance_logs)
      .all
  end

  def staff_performance_for(service)
    service
      .staff_performance_logs
      .actioned_by(@user_id)
      .in_part(@part)
      .created_after(@date_start)
      .created_before(@date_end)
      .all
  end

  def staff_performance_summary
    StaffPerformanceLog
      .actioned_by(@user_id)
      .in_part(@part)
      .created_after(@date_start)
      .created_before(@date_end)
  end
end
