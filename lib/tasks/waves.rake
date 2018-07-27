namespace :waves do
  # this task should be executed with `clock.rb` (not with rake)
  task close_terminated_vessels: :environment do
    Register::Vessel.termination_notice_issued.each do |vessel|
      section_notice = vessel.section_notices.last

      next unless section_notice
      next if section_notice.updated_at > 7.days.ago

      vessel.update_attribute(:frozen_at, nil)
      vessel.restore_active_state!

      submission =
        Builders::CompletedSubmissionBuilder.create(
          :termination_notice,
          vessel.part,
          vessel,
          section_notice.actioned_by)

      Builders::ClosedRegistrationBuilder
        .create(submission,
                Time.zone.now,
                DeprecableTask.new(:termination_notice).description)
    end
  end
end
