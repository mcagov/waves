require "rails_helper"

feature "User cancels a task", type: :feature, js: true do
  before do
    visit_claimed_task
    @task = Submission::Task.last
    @submission = @task.submission
  end

  scenario "in general" do
    within("#actions") { click_on "Cancel Task" }

    within(".modal.fade.in") do
      select "Rejected (by RSS)", from: "Reason for cancelling task"

      find("#cancel_modal_trix_input_notification", visible: false)
        .set("Sorry!")

      click_on "Cancel Task"
    end

    click_on "Cancelled Tasks"
    expect(Notification::Cancellation.last.body).to have_text("Sorry!")
    creates_a_work_log_entry("Submission::Task", :cancellation)

    click_on(@submission.vessel.name)

    within(".breadcrumb") do
      expect(page).to have_link("Cancelled Tasks", href: tasks_cancelled_path)
    end

    within("#prompt") do
      expect(page).to have_text(
        /Task Cancelled by #{@task.claimant.to_s} on .*./
      )
    end
  end

  scenario "without sending an email" do
    within("#actions") { click_on "Cancel Task" }
    uncheck("Send a cancellation email to #{Submission.last.applicant_name}")
    within("#cancel-task") { click_on "Cancel Task" }
    expect(Notification::Cancellation.count).to eq(0)
  end

  scenario "without an applicant" do
    within("#summary") { click_on(Submission.last.applicant_name) }
    fill_in("Email Recipient Name", with: "")
    click_on("Save Notification Recipient")

    within("#actions") { click_on "Cancel Task" }
    expect(page).to have_text("email cannot be sent without an Email Recipient")
  end
end
