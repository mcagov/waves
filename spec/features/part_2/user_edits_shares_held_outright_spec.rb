require "rails_helper"

xdescribe "User edits shares held outright", js: :true do
  scenario "in general" do
    visit_name_approved_part_2_submission
    click_on("Owners & Shareholding")

    expect(page)
      .to have_css("#total_shares", text: "Total shares allocated: 64")

    within("#shares_held_outright") { click_on("64") }

    within(".modal-content") do
      find("#declaration_shares_held").set("16")
      click_on("Save")
    end

    expect(page)
      .to have_css(
        "#total_shares", text: "allocated: 16 (48 shares un-allocated)")

    # Here we add Bob via the UI and check that the shareholding div
    # is re-rendered, allowing us to assign him some shares
    click_on("Add Individual Owner")
    fill_in("Name", with: "BOB BOLD")
    click_on("Save Individual Owner")

    within("#shares_held_outright") { click_on("0") }

    within(".modal-content") do
      find("#declaration_shares_held").set("48")
      click_on("Save")
    end

    expect(page).to have_css("#total_shares", text: "allocated: 64")
  end
end
