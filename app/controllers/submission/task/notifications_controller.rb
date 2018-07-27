class Submission::Task::NotificationsController < InternalPagesController
  before_action :load_submission
  before_action :load_task

  def show
    @submission = Decorators::Submission.new(@submission)
    case params[:template]
    when "refer"
      render :refer
    when "cancel"
      render :cancel
    end
  end

  def cancel
    if params[:send_email].present?
      Notification::Cancellation.create(parsed_notification_params)
    end

    flash[:notice] = "You have successfully cancelled that task"
    @task.cancel!

    log_work!(@task, @task, :cancellation)
    redirect_to tasks_my_tasks_path
  end

  def refer
    if params[:send_email].present?
      Notification::Referral.create(parsed_notification_params)
    end

    flash[:notice] = "You have successfully referred that task"
    @task.update_attribute(
      :referred_until, notification_params[:actionable_at])

    @task.refer!

    log_work!(@task, @task, :referred)
    redirect_to tasks_my_tasks_path
  end

  private

  def load_submission
    @submission = Submission.find(params[:submission_id])
  end

  def load_task
    @task = Submission::Task.find(params[:task_id])
  end

  def notification_params
    params.require(:notification).permit(:subject, :body, :actionable_at)
  end

  def parsed_notification_params
    {
      notifiable: @submission,
      subject: notification_params[:subject],
      body: notification_params[:body],
      actioned_by: current_user,
      recipient_email: @submission.applicant_email,
      recipient_name: @submission.applicant_name,
    }
  end
end
