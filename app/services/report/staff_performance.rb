class Report::StaffPerformance < Report
  def title
    "Staff Performance"
  end

  def sub_report
    :staff_performance_by_task
  end

  def filter_fields
    [:filter_part, :filter_date_range]
  end

  def headings
    [:task_type, :total_transactions, :top_performer]
  end

  def date_range_label
    "Application Received"
  end

  def results
    ApplicationType.all.map do |task_type|
      submission_ids = submission_ids_for(task_type)
      data_elements =
        [
          DeprecableTask.new(task_type[1]).description,
          submission_ids.length,
          top_performer(submission_ids),
        ]

      Result.new(data_elements, task: task_type[1])
    end
  end

  def top_performer(submission_ids)
    result = Submission.select("claimant_id, count(*) AS total")
                       .includes(:claimant)
                       .where(id: submission_ids)
                       .group(:claimant_id)
                       .order("total desc")
                       .first

    return "-" if result.blank? || result.claimant.blank?
    "#{result.claimant} (#{result.total})"
  end

  def submission_ids_for(task_type)
    scoped_query = Submission.where(application_type: task_type)
    scoped_query = filter_by_received_at(scoped_query)
    scoped_query = filter_by_part(scoped_query)
    scoped_query.completed.pluck(:id)
  end
end
