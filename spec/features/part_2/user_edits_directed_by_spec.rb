require "rails_helper"

xdescribe "User edits Directed & Controlled By", js: :true do
  scenario "in general" do
    visit_name_approved_part_2_submission
    click_on("Owners & Shareholding")
    click_on("Add Directed & Controlled By")

    within(".modal.fade.in") do
      expect_postcode_lookup
      fill_in("Name", with: "BOB BOLD")
      select("BELGIAN", from: "Nationality")
      click_on("Save")
    end

    expect(page).to have_css(".directed_by-name", text: "BOB BOLD")
    expect(page).to have_css(".directed_by-nationality", text: "BELGIAN")

    click_on("BOB BOLD")
    select("SPANISH", from: "Nationality")
    click_on("Save")

    expect(page).to have_css(".directed_by-nationality", text: "SPANISH")

    within("#directed_by") do
      click_on("Remove")
      expect(page).not_to have_css(".directed_by-name")
      expect(Submission.last.directed_bys).to be_empty
    end
  end
end
