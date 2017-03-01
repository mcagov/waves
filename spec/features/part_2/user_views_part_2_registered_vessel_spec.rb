require "rails_helper"

describe "User views Part 2 registered vessel", type: :feature, js: true do
  before do
    @vessel = create(:registered_vessel, part: :part_2)
    login_to_part_2
    visit vessels_path
    click_on(@vessel.name.upcase)
  end

  scenario "tabs" do
    click_on("Vessel Information")
    expect(page).to have_css("li.active a#vessel-tab")

    click_on("Engines")
    expect(page).to have_css("li.active a#engines-tab")

    click_on("Owners & Shareholding")
    expect(page).to have_css("li.active a#owners-tab")

    click_on("Mortgages")
    expect(page).to have_css("li.active a#mortgages-tab")

    click_on("Certificates & Documents")
    expect(page).to have_css("li.active a#certificates-tab")

    click_on("Owners & Shareholding")
    expect(page).to have_css("li.active a#owners-tab")

    click_on("Agents & Representative Persons")
    expect(page).to have_css("li.active a#agents-tab")

    click_on("Application History")
    expect(page).to have_css("li.active a#submissions-tab")

    click_on("Correspondence")
    expect(page).to have_css("li.active a#correspondence-tab")

    click_on("Notes")
    expect(page).to have_css("li.active a#notes-tab")
  end
end
