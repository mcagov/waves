require "rails_helper"

xdescribe "User edits mortgagors", js: :true do
  scenario "adding an owner, then adding that owner as a mortgagor" do
    visit_name_approved_part_1_submission
    click_on("Owners")
    click_on("Add Individual Owner")

    fill_in("Name", with: "BOB BOLD")
    fill_in("Address 1", with: "10 Upping St")
    click_on("Save Individual Owner")

    click_on("Mortgages")
    click_on("Add Mortgage")

    within(".modal.fade.in") do
      within("#mortgagors") do
        expect(page).to have_field("Name of Mortgagor")
        select("BOB BOLD", from: "Select an Owner")
        expect(page).not_to have_field("Name of Mortgagor")
      end

      click_on("Add Mortgage")
    end

    within("#mortgages_tab") do
      expect(page).to have_css(".mortgagors", text: "BOB BOLD")
    end
    expect(Mortgagor.last.address_1).to eq("10 UPPING ST")
  end
end
