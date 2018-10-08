require "rails_helper"

describe "User sets the managing owner", js: true do
  scenario "adding an owner and setting them as managing owner" do
    visit_claimed_task(
      submission: create(:submission, :part_2_vessel),
      service: create(:service, :update_registry_details))

    click_on("Owners & Shareholding")
    click_on("Add Individual Owner")

    fill_in("Name", with: "BOB BOLD")
    select("UNITED KINGDOM", from: "Country")
    click_on("Save Individual Owner")

    click_on("Add Managing Owner")
    select("BOB BOLD", from: "Name")
    click_on("Save Managing Owner")

    expect(page).to have_css(".managing_owner-name", text: "BOB BOLD")
  end
end
