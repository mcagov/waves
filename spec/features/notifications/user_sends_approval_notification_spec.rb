require "rails_helper"

describe "User sends application approval notification", js: true do
  scenario "in general" do
    visit_completed_task(
      submission: create(
        :submission, :part_3_vessel,
        registration: create(:registration),
        print_jobs: [
          create(:print_job, template: :registration_certificate),
          create(:print_job, template: :current_transcript)]))

    within("#application-tools") { click_on(application_approval_email_link) }

    within(".modal.fade.in") do
      expect(find_field("notification_application_approval[subject]").value)
        .to eq("UK ship registry, reference no: #{@submission.ref_no}")

      find_field("notification_application_approval[subject]").set("Hello")
      check(@submission.applicant.email_description)
      check(@submission.owners.first.email_description)

      expect(find("trix-editor").value).to match(/completed/)
      find("trix-editor").click.set("The message")

      check("Certificate of Registry")
      check("Current Transcript")
      click_on("Send")
    end

    expect(page)
      .to have_text("Emails have been sent to the selected recipients")

    notification =
      Notification.find_by(recipient_email: @submission.applicant_email)

    expect(notification.recipient_name).to eq(@submission.applicant_name)
    expect(notification.subject).to eq("Hello")
    expect(notification.body).to match(/The message/)

    expect(notification.attachments)
      .to match(%w(registration_certificate current_transcript))

    expect(Notification::ApplicationApproval.count).to eq(2)
  end

  scenario "when there is no recipient" do
    task = create(:completed_task)

    Submission.update_all(applicant_email: nil)
    Customer.update_all(email: nil)
    login(task.claimant, task.submission.part)
    visit submission_task_path(task.submission, task)

    within("#application-tools") do
      click_on(application_approval_email_link)
      expect(page).to have_text("An email cannot be sent without a recipient")
    end
  end

  scenario "when no recipient was selected" do
    task = create(:completed_task)

    login(task.claimant, task.submission.part)
    visit submission_task_path(task.submission, task)

    within("#application-tools") do
      click_on(application_approval_email_link)
    end

    within(".modal.fade.in") do
      click_on("Send")
    end

    expect(page).to have_text("A recipient must be selected")
  end

  scenario "when the submission has no completed task" do
    visit_claimed_task

    expect(page).not_to have_link(application_approval_email_link)
  end
end

def application_approval_email_link
  "Application Approval Email"
end
