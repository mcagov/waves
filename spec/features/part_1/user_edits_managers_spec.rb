require "rails_helper"

describe "User edits managers", js: :true do
  scenario "in general" do
    visit_claimed_task(
      submission: create(:submission, :part_1_vessel),
      service: create(:service, :update_registry_details))

    expect_managers(true)

    click_on("Managers")
    click_on("Add Manager")

    within(".modal.fade.in") do
      within("#manager") do
        expect_postcode_lookup
        fill_in("Name", with: "BOB BOLD")
        fill_in("IMO Number", with: "1234567")
      end

      within("#safety_management") do
        fill_in("Address 1", with: "SM ADDRESS 1")
      end

      click_on("Save Manager")
    end

    expect(page).to have_css(".manager-imo_number", text: "1234567")
    expect(page).to have_css(".safety_management", text: "SM ADDRESS 1")

    click_on("BOB BOLD")

    within(".modal.fade.in") do
      within("#safety_management") do
        check("Use address above")
      end

      click_on("Save Manager")
    end

    expect(page)
      .to have_css(".safety_management", text: "Safety Management: As above")

    within("#managers") do
      click_on("Remove")
      expect(page).not_to have_css(".manager-name")
      expect(Submission.last.managers).to be_empty
    end
  end
end
