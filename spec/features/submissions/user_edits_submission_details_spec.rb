require "rails_helper"

describe "User edits submission details", js: true do
  before do
    visit_assigned_submission
    click_on "Edit Application"
  end

  scenario "vessel and applicant details" do
    fill_in("Approved Vessel Name", with: "BOAT")
    fill_in("Applicant Name", with: "ANNIE")
    fill_in("Applicant's Email", with: "annie@example.com")
    click_on("Save Application")

    expect(page).to have_css(".vessel-name", text: "BOAT")
    expect(page)
      .to have_css(".applicant-name", text: "ANNIE (annie@example.com)")
  end
end