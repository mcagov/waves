class Report::StaffPerformance < Report
  def title
    "Staff Performance"
  end

  def columns
    [:task_type, :total_transactions, :top_performer]
  end

  def results
    Task.all_task_types.map do |task_type|
      submission_ids = submission_ids_for(task_type)
      data_elements =
        [
          Task.new(task_type[1]).description,
          submission_ids.length,
          top_performer(submission_ids),
        ]

      Result.new(data_elements, task_type[1])
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
    scoped_query = Submission.where(task: task_type)
    scoped_query = filter_by_completed_at(scoped_query)
    scoped_query = filter_by_part(scoped_query)
    scoped_query.completed.pluck(:id)
  end
end
