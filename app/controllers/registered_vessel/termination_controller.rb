class RegisteredVessel::TerminationController < InternalPagesController
  before_action :load_vessel

  def create
    build_completed_submission
    process_termination_submission

    log_work!(@submission, @submission, :termination_notice)

    redirect_to submission_approval_path(@submission)
  end

  private

  def build_completed_submission
    @submission =
      Builders::CompletedSubmissionBuilder.create(
        :termination_notice,
        current_activity.part,
        @vessel,
        current_user)
  end

  def process_termination_submission
    @vessel.update_attribute(:frozen_at, Time.zone.now)
    @vessel.issue_termination_notice!
    section_notice = @vessel.section_notices.last
    section_notice.update_column(:updated_at, Time.zone.now)
    build_print_job(section_notice)
  end

  def build_print_job(section_notice)
    templates = DeprecableTask.new(:termination_notice).print_job_templates
    templates.each do |template|
      PrintJob.create(
        printable: section_notice,
        part: @submission.part,
        template: template,
        submission: @submission)
    end
  end
end
