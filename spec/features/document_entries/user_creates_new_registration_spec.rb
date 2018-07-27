require "rails_helper"

feature "User creates a new registration", type: :feature do
  before do
    login_to_part_3
    visit open_submissions_path

    click_on("Document Entry")
    within(".modal#start-new-application") { click_on("New Registration") }

    select("New Registration", from: "Application Type")
    fill_in("Vessel Name", with: "MY BOAT")

    fill_in("Date Received", with: "1/1/2016")
    fill_in("Applicant Name", with: "Bob")
    fill_in("Applicant's Email Address", with: "bob@example.com")
  end

  scenario "in general" do
    click_on("Save Application")
    expect(page).to have_text("saved to the unclaimed tasks queue")
    expect(page).to have_current_path(tasks_my_tasks_path)
    expect(Submission.last).to be_unassigned
  end

  scenario "with an application receipt email" do
    check("Send an Application Receipt email")
    click_on("Save Application")

    expect(Notification::ApplicationReceipt.last.recipient_email)
      .to eq("bob@example.com")
    expect(page)
      .to have_text("An Application Receipt has been sent to bob@example.com")
  end

  scenario "without an application receipt email" do
    click_on("Save Application")

    expect(Notification::ApplicationReceipt.last).to be_nil
  end

  scenario "when the applicant is an agent" do
    check("Applicant is Agent")
    click_on("Save Application")

    expect(Submission.last.agent.name).to eq("Bob")
  end
end
