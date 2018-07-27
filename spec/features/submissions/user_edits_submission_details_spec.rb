require "rails_helper"

describe "User edits submission details", js: true do
  before do
    visit_claimed_task
  end

  scenario "vessel details" do
    click_on "Edit Application"
    fill_in("Approved Vessel Name", with: "BOAT")
    click_on("Save Application")

    expect(page).to have_css(".vessel-name", text: "BOAT")
  end

  scenario "notification recipient" do
    within("#summary") { click_on(Submission.last.applicant_name) }

    within(".modal.fade.in") { expect_postcode_lookup }

    fill_in("Email Recipient Name", with: "ANNIE")
    fill_in("Email", with: "annie@example.com")

    fill_in("Postal Recipient Name", with: "ALICE")
    fill_in("Address 1", with: "Address 1")
    fill_in("Address 2", with: "Address 2")
    fill_in("Address 3", with: "Address 3")
    fill_in("Town or City", with: "Town")
    fill_in("Postcode", with: "POC123")
    select("FRANCE", from: "Country")
    click_on("Save")

    expect(page).to have_css(
      ".applicant-email", text: "ANNIE (annie@example.com)")

    expect(page).to have_css(
      ".applicant-delivery-address",
      text: "ALICE ADDRESS 1 ADDRESS 2 ADDRESS 3 TOWN FRANCE POC123")
  end
end
