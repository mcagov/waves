class SubmissionsController < InternalPagesController
  include InitNewSubmission

  before_action :prevent_read_only!, except: [:show, :edit]
  before_action :load_submission,
                only: [:show, :edit, :update, :close]
  before_action :check_redirection_policy, only: [:show]

  before_action :enable_readonly, only: [:show, :edit]

  def new
    @submission =
      Submission.new(
        submission_params.merge(
          received_at: Time.zone.today,
          part: current_activity.part))
  end

  def create
    init_new_submission

    if @submission.save
      send_application_receipt_email
      flash[:notice] ||= "The application has been created"
      redirect_to submission_path(@submission)
    else
      render :new
    end
  end

  def show
    @submission = Decorators::Submission.new(@submission)
  end

  def edit
    @submission = Decorators::Submission.new(@submission)
    @task = Submission::Task.find(params[:task_id])

    raise "Task not found" unless @task
  end

  def update
    if @submission.update_attributes(submission_params)
      render_update_js
    else
      render :edit
    end
  end

  def close
    @submission.close!
    flash[:notice] ||= "The application has been closed"

    redirect_to tasks_my_tasks_path
  end

  def open
    @submissions = submissions_scope.active
    @page_title = "Open Applications"
    render :index
  end

  def closed
    @submissions = submissions_scope.closed
    @page_title = "Closed Applications"
    render :index
  end

  protected

  def load_submission # rubocop:disable Metrics/MethodLength
    @submission =
      Submission.includes(
        [
          { payments: [:remittance] }, { declarations: [:notification] },
          { declaration_groups: [:declaration_owners] },
          { documents: [:assets, :actioned_by] },
          { work_logs: [:actioned_by] }, { charterers: [:charter_parties] },
          { mortgages: [:mortgagees, :mortgagors] }, :carving_and_markings,
          :managers, :declarations, :engines, :correspondences, :notes,
          :print_jobs, :notifications, :beneficial_owners]
      ).find(params[:id])

    ensure_current_part_for(@submission.part)
  end

  def submission_params
    return {} unless params[:submission]
    params.require(:submission).permit(
      :part, :application_type, :received_at, :applicant_name,
      :applicant_is_agent, :applicant_email, :vessel_reg_no,
      :documents_received,
      vessel: Submission::Vessel::ATTRIBUTES,
      delivery_address: Submission::DeliveryAddress::ATTRIBUTES)
  end

  def check_redirection_policy
    default_task = @submission.tasks.confirmed.first
    if default_task
      return redirect_to(
        submission_task_path(@submission, @submission.tasks.confirmed.first))
    else
      return redirect_to(submission_tasks_path(@submission))
    end
  end

  def render_update_js
    respond_to do |format|
      format.html do
        flash[:notice] = "The application has been updated"
        redirect_to submission_path(@submission)
      end
      format.js do
        view_mode = Activity.new(@submission.part).view_mode
        render "/submissions/#{view_mode}/forms/update.js"
      end
    end
  end

  def submissions_scope
    Submission
      .in_part(current_activity.part)
      .includes(:tasks, payments: [:remittance])
      .paginate(page: params[:page], per_page: 50)
  end
end
