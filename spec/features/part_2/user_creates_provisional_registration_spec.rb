require "rails_helper"

xfeature "User creates a provisional registration", type: :feature, js: true do
  scenario "in general" do
    login_to_part_2
    visit open_submissions_path

    click_on("Document Entry")
    within(".modal#start-new-application") { click_on("New Registration") }
    select("Provisional Registration", from: "Application Type")
    fill_in("Vessel Name", with: "MY BOAT")
    click_on("Save Application")

    expect(page).to have_text("saved to the unclaimed tasks queue")
    expect(Submission.last.vessel.name).to eq("MY BOAT")
  end
end
