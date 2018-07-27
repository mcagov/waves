require "rails_helper"

feature "User creates a new registration for part 1", type: :feature do
  scenario "in general" do
    login_to_part_1
    visit open_submissions_path

    click_on("Document Entry")
    within(".modal#start-new-application") { click_on("New Registration") }

    select("Pleasure", from: "Registration Type")
    fill_in("Vessel Name", with: "MY BOAT")

    click_on("Save Application")
    visit open_submissions_path

    expect(page)
      .to have_css("#submissions .registration_type", text: "Pleasure")
  end
end
