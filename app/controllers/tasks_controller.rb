class TasksController < InternalPagesController
  def my_tasks
    @tasks =
      task_scope.claimed_by(current_user).order("target_date asc")
  end

  def team_tasks
    @tasks = task_scope.claimed.order("target_date asc")
  end

  def unclaimed
    @filter_registration_type = params[:filter_registration_type] || "all"

    query =
      task_scope
      .unclaimed

    query = filter_by_registration_type(query)
    @tasks = query.order("target_date asc")
  end

  def incomplete
    @tasks = task_scope.incomplete.order("target_date asc")
  end

  def referred
    @tasks = task_scope.order("submission_tasks.referred_until desc").referred
  end

  def cancelled
    @tasks = task_scope.order("submission_tasks.updated_at desc").cancelled
  end

  def next_task
    if (task = task_scope.claimed_by(current_user).first)
      return redirect_to submission_task_path(task.submission, task)
    else
      return redirect_to tasks_my_tasks_path
    end
  end

  private

  def task_scope
    Submission::Task
      .in_part(current_activity.part)
      .includes(:claimant, :submission, :service)
      .paginate(page: params[:page], per_page: 50)
      .active
  end

  def filter_by_registration_type(query)
    case @filter_registration_type
    when "all"
      query
    when "not_set"
      query.where("#{reg_type_sql} is null")
    else
      query.where(
        "(UPPER#{reg_type_sql} = ?)", @filter_registration_type.upcase)
    end
  end

  def reg_type_sql
    "(submissions.changeset#>>'{vessel_info, registration_type}')"
  end
end
