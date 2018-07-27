class RegisteredVessel::SectionNoticeController < InternalPagesController
  before_action :load_vessel

  def create
    build_completed_submission
    process_section_notice_submission

    log_work!(@submission, @submission, :section_notice)

    redirect_to submission_approval_path(@submission)
  end

  private

  def build_completed_submission
    @submission =
      Builders::CompletedSubmissionBuilder.create(
        :section_notice,
        current_activity.part,
        @vessel,
        current_user)
  end

  def process_section_notice_submission
    @vessel.update_attribute(:frozen_at, Time.zone.now) unless @vessel.frozen?

    DeprecableTask.new(:section_notice).print_job_templates.each do |template|
      PrintJob.create(
        printable: build_section_notice,
        part: @submission.part,
        template: template,
        submission: @submission)
    end

    @vessel.issue_section_notice!
  end

  def build_section_notice
    Register::SectionNotice.create(
      noteable: @vessel,
      actioned_by: current_user,
      subject: section_notice_params[:subject],
      content: section_notice_params[:content])
  end

  def section_notice_params
    params.require(:register_section_notice).permit(:subject, :content)
  end
end
