class Submission::SignaturesController < InternalPagesController
  before_action :load_submission

  def show
  end

  def update
    @submission.assign_attributes(submission_params)

    if @submission.save
      successful_redirect
    else
      render :show
    end
  end

  protected

  def submission_params
    params.require(:submission).permit(:part, :application_type, :vessel_reg_no)
  end

  def successful_redirect
    if @submission.part.to_sym == current_activity.part
      redirect_to submission_path(@submission)
    else
      @submission.unclaimed! if @submission.assigned?
      render :part_changed
    end
  end
end
