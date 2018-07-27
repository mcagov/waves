require "rails_helper"

xdescribe "User edits benifical owners", js: :true do
  scenario "in general" do
    visit_name_approved_part_2_submission
    click_on("Owners & Shareholding")
    click_on("Add Beneficial Owner")

    within(".modal.fade.in") do
      expect_postcode_lookup
      fill_in("Name", with: "BOB BOLD")
      fill_in("IMO Number", with: "1234567")
      select("(b)", from: "Status")
      click_on("Save Beneficial Owner")
    end

    expect(page).to have_css(".beneficial_owner-imo_number", text: "1234567")

    click_on("BOB BOLD")
    fill_in("IMO Number", with: "7654321")
    click_on("Save Beneficial Owner")

    expect(page).to have_css(".beneficial_owner-imo_number", text: "7654321")

    within("#beneficial_owners") do
      click_on("Remove")
      expect(page).not_to have_css(".beneficial_owner-name")
      expect(Submission.last.beneficial_owners).to be_empty
    end
  end
end
