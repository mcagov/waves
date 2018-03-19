require "rails_helper"

feature "User cancels a submission", type: :feature, js: true do
  before do
    visit_assigned_submission
    @submission = Submission.last
  end

  scenario "in general" do
    reg_officer = @submission.claimant.to_s

    within("#actions") { click_on "Cancel Application" }

    within(".modal.fade.in") do
      select "Rejected (by RSS)", from: "Reason for cancelling application"

      find("#cancel_modal_trix_input_notification", visible: false)
        .set("Sorry!")

      click_on "Cancel Application"
    end

    click_on "Cancelled Applications"
    expect(Notification::Cancellation.last.body).to have_text("Sorry!")
    creates_a_work_log_entry("Submission", :cancellation)

    click_on(@submission.vessel.name)

    within("#prompt") do
      expect(page).to have_text(
        /Application Cancelled by #{reg_officer} on .*. Rejected \(by RSS\)/
      )
    end
  end

  scenario "without sending an email" do
    within("#actions") { click_on "Cancel Application" }
    uncheck("Send a cancellation email to #{Submission.last.applicant_name}")
    within("#cancel-application") { click_on "Cancel Application" }
    expect(Notification::Cancellation.count).to eq(0)
  end

  scenario "without an applicant" do
    within("#summary") { click_on(Submission.last.applicant_name) }
    fill_in("Email Recipient Name", with: "")
    click_on("Save Notification Recipient")

    within("#actions") { click_on "Cancel Application" }
    expect(page).to have_text("email cannot be sent without an Email Recipient")
  end
end
