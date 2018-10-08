class InternalPagesController < ApplicationController
  layout "internal"

  before_action :authenticate_user!

  def render_pdf(pdf, filename)
    send_data pdf.render,
              filename: filename,
              type: "application/pdf",
              disposition: "inline"
  end

  private

  def current_activity
    session[:current_activity] ||= :part_3
    Activity.new(session[:current_activity])
  end
  helper_method :current_activity

  def activity_root(activity)
    session[:current_activity] = activity.to_sym
    current_activity.root_path(current_user)
  end

  def log_work!(task, logged_info, description)
    WorkLog.create(
      task: task,
      logged_info: logged_info.to_json,
      description: description,
      actioned_by: current_user,
      part: current_activity.part)
  end

  def load_vessel
    @vessel = Register::Vessel.find(params[:vessel_id])
  end

  def load_submission
    @submission =
      Submission.includes(:declarations).find(params[:submission_id])
  end

  def load_task
    @task = Submission::Task.find(params[:task_id]) if params[:task_id]
  end

  def ensure_current_part_for(part)
    session[:current_activity] = part unless current_activity.matches?(part)
  end

  def enable_readonly
    @readonly = Policies::Actions.readonly?(@task, current_user)
  end

  def prevent_readonly_user!
    access_denied! if current_user.read_only?
  end

  def system_manager_only!
    access_denied! unless current_user.system_manager?
  end

  def access_denied!
    render file: "public/401.html", status: :unauthorized, layout: false
  end
end
