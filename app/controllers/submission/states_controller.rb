class Submission::StatesController < InternalPagesController
  before_action :load_submission

  def claim
    @submission.claimed!(current_user)

    respond_to do |format|
      format.html do
        flash[:notice] = "You have succesfully claimed this application"
        redirect_to submission_path(@submission)
      end
      format.js { render "tasks/actions/claim_button" }
    end
  end

  def unclaim
    @submission.unclaimed!

    respond_to do |format|
      format.html do
        flash[:notice] = "Application has been moved into Unclaimed Tasks"
        redirect_to tasks_my_tasks_path
      end
      format.js { render "tasks/actions/claim_button" }
    end
  end

  def claim_referral
    @submission.unreferred!
    @submission.claimed!(current_user)

    flash[:notice] = "You have succesfully claimed this application"
    redirect_to tasks_my_tasks_path
  end

  protected

  def load_submission
    @submission =
      Submission.in_part(current_activity.part).find(params[:submission_id])
  end
end