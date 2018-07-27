class RegisteredVessel::ForcedClosureController < InternalPagesController
  before_action :load_vessel

  def create
    complete_forced_closure_submission
    build_print_jobs
    log_work!(@submission, @submission, :forced_closure)

    redirect_to submission_approval_path(@submission)
  end

  private

  def complete_forced_closure_submission
    @submission =
      Builders::CompletedSubmissionBuilder.create(
        :forced_closure, current_activity.part, @vessel, current_user)

    @current_registration =
      Builders::ClosedRegistrationBuilder.create(
        @submission,
        Time.zone.now,
        DeprecableTask.new(:forced_closure).description)
  end

  def build_print_jobs
    Builders::PrintJobBuilder
      .create(
        @submission,
        @current_registration,
        @submission.part,
        [:forced_closure, :current_transcript])
  end
end
