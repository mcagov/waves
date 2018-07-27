class Submission::TasksController < InternalPagesController
  before_action :load_submission
  before_action :load_task, except: [:index, :create, :confirm]

  def index
  end

  def create
    @submission_task = Submission::Task.new(submission_task_params)
    @submission_task.submission = @submission
    @submission_task.save

    flash[:notice] = "The task has been added"
    redirect_to submission_tasks_path(@submission)
  end

  def confirm
    @submission.tasks.initialising.map(&:confirm!)

    flash[:notice] = "The tasks have been confirmed"
    redirect_to submission_tasks_path(@submission)
  end

  def destroy
    @task.destroy

    flash[:notice] = "The task has been confirmed"
    redirect_to submission_tasks_path(@submission)
  end

  def update
    @task.update_attributes(submission_task_params)

    flash[:notice] = "The task has been updated"
    redirect_to submission_tasks_path(@submission)
  end

  def show
    @submission = Decorators::Submission.new(@submission)
  end

  def claim
    @task.claim!(current_user)

    respond_to do |format|
      format.html do
        flash[:notice] = "You have successfully claimed this task"
        redirect_to submission_task_path(@submission, @task)
      end
      format.js { render "tasks/actions/claim_button" }
    end
  end

  def unclaim
    @task.unclaim!

    respond_to do |format|
      format.html do
        flash[:notice] = "Task has been moved into Unclaimed Tasks"
        redirect_to tasks_my_tasks_path
      end
      format.js { render "tasks/actions/claim_button" }
    end
  end

  # def claim_referral
  #   @submission.unreferred!
  #   @submission.claimed!(current_user)

  #   log_work!(@submission, @submission, :referral_reclaimed)
  #   flash[:notice] = "You have successfully claimed this application"
  #   redirect_to tasks_my_tasks_path
  # end

  private

  def submission_task_params
    params.require(:submission_task).permit(
      :service_id, :service_level, :start_date)
  end

  def load_task
    @task = @submission.tasks.find(params[:id])
  end
end
