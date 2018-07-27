require "rails_helper"

xdescribe "User edits submission signature" do
  before do
    create(:registered_vessel, reg_no: "SSR200001")
    visit_claimed_task
    click_on("New Registration")
  end

  scenario "toggling the task type" do
    select("Change of Vessel details", from: "Application Type")
    fill_in("Official Number", with: "SSR200001")
    click_on("Save")

    expect(Submission.last.registered_vessel).to be_present
    click_on("Change of Vessel details")
  end

  scenario "changing the part of the registry" do
    select("Part I", from: "Part of the Register")
    click_on("Save")

    expect(page).to have_text("The application has been moved to Part I")
    expect(Submission.last.registered_vessel).to be_falsey
    expect(Submission.last).to be_unassigned
  end
end
