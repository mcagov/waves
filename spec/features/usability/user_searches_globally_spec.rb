require "rails_helper"

describe "User searches globally", js: true do
  before do
    create(:submission, ref_no: "ABC456")
    create(:registered_vessel, reg_no: "MYBOAT", name: "SEARCH BOAT")

    login_to_part_1

    visit root_path

    click_on("Search the Registry")
  end

  scenario "for a submission" do
    search_for("ABC456")

    click_on("Applications (1)")
    click_on("Boaty McBoatface")
    expect(page).to have_css("h1", text: "ABC456")
  end

  scenario "for a vessel" do
    search_for("MYBOAT")

    click_on("Registry (1)")
    click_on("SEARCH BOAT")
    expect(page).to have_css("h1", text: "SEARCH BOAT")
  end
end
