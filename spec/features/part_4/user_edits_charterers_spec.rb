require "rails_helper"

xdescribe "User edits charterers", js: :true do
  before do
    visit_name_approved_part_4_submission
    click_on("Charterers")
    click_on("Add Bareboat Charter")

    within(".modal.fade.in") do
      fill_in("Reference Number", with: "REF 1")
      fill_in("Start Date", with: "01/02/2001")
      fill_in("End Date", with: "01/02/2004")

      click_on("Add Bareboat Charter")
    end
  end

  scenario "editing a charterer" do
    within("#charterers_tab") do
      expect(page).to have_css(".reference_number", text: "REF 1")
      expect(page).to have_css(".start_date", text: "01/02/2001")
      expect(page).to have_css(".end_date", text: "01/02/2004")
    end

    click_on("Edit")
    within(".modal.fade.in") do
      fill_in("Reference Number", with: "REF 1")
      click_on("Save Bareboat Charter")
    end

    within("#charterers_tab") do
      expect(page).to have_css(".reference_number", text: "REF 1")
    end
  end

  scenario "removing a charterer" do
    within("#charterers_tab") do
      click_on("Remove")
    end

    within("#charterers_tab") do
      expect(page).not_to have_css(".reference_number")
    end
  end

  scenario "adding, editing an individual party" do
    within("#charterers_tab") do
      click_on("Add Individual Party")
    end

    within(".modal.fade.in") do
      expect_postcode_lookup

      fill_in("Charterer Name", with: "BOB BOLD")
      select("(b)", from: "Status")
      within(".charter_party_declaration_signed") { choose("No") }
      click_on("Save Individual Party")
    end

    expect(page).to have_css(".name", text: "BOB BOLD")
    expect(page).to have_css(".status", text: "Status B")
    expect(page).to have_css(".declaration", text: "Pending Declaration")

    click_on("BOB BOLD")
    within(".modal.fade.in") do
      within(".charter_party_declaration_signed") { choose("Yes") }
      click_on("Save Individual Party")
    end

    within("#charterers_tab") do
      expect(page).to have_css(".declaration", text: "Declaration Signed")
    end

    within(".remove-charter-party") { click_on("Remove") }
    expect(page).not_to have_text("BOB BOLD")
  end

  scenario "adding a corporate party" do
    within("#charterers_tab") do
      click_on("Add Corporate Party")
    end

    within(".modal.fade.in") do
      expect_postcode_lookup
      expect_alt_postcode_lookup

      fill_in("Company Name", with: "BOB INC")
      select("ANTIGUA", from: "Country of Incorporation")
      click_on("Save Corporate Party")
    end

    within(".name") { expect(page).to have_link("BOB INC") }
    expect(page).to have_css(".country_of_incorporation", text: "ANTIGUA")
    within(".remove-charter-party") { expect(page).to have_link("Remove") }
  end

  scenario "adding a charter party and making them the correspondent" do
    click_on("Add Individual Party")

    fill_in("Charterer Name", with: "CAROL CORRESPONDENT")
    click_on("Save Individual Party")

    click_on("Owners")
    within("#correspondent") do
      click_on(Submission.last.correspondent)
      select("CAROL CORRESPONDENT", from: "Name")
      click_on("Save Correspondent")
    end

    expect(page).to have_css(".correspondent-name", text: "CAROL CORRESPONDENT")
  end
end
