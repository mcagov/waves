class Builders::NotificationBuilder
  class << self
    def application_approval(submission, actioned_by, attachments = "")
      Notification::ApplicationApproval.create(
        recipient_email: submission.applicant_email,
        recipient_name: submission.applicant_name,
        notifiable: submission,
        subject: submission.job_type,
        actioned_by: actioned_by,
        attachments: attachments)
    end
  end
end