class RegisteredVessel::ClosureController < InternalPagesController
  before_action :load_vessel

  def create
    if @vessel.registration_status != :closed
      complete_closure_submission
      log_work!(@submission, @submission, :registrar_closure)
    else
      complete_restore_closure_submission
      log_work!(@submission, @submission, :registrar_restores_closure)
    end

    redirect_to vessel_path(@vessel)
  end

  private

  def complete_closure_submission
    @submission =
      Builders::CompletedSubmissionBuilder.create(
        :registrar_closure,
        current_activity.part,
        @vessel,
        current_user)

    task_description = DeprecableTask.new(:registrar_closure).description
    Builders::ClosedRegistrationBuilder
      .create(@submission, Time.zone.now, task_description)
  end

  def complete_restore_closure_submission
    @submission =
      Builders::CompletedSubmissionBuilder.create(
        :registrar_restores_closure,
        current_activity.part,
        @vessel,
        current_user)

    Builders::RestoreClosedRegistrationBuilder.create(@submission)
  end
end
