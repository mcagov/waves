require "rails_helper"

describe "User looks up an open application", js: true do
  before do
    @submission = create(:submission)
    login_to_part_3
    visit open_submissions_path
    click_on("Document Entry")
  end

  scenario "searching for an open application" do
    within(".modal#start-new-application") do
      click_on("Search for Open Application")
    end

    within(".modal#search-for-submission") do
      search_for(@submission.ref_no)
      within("#submissions") { click_on("View this Application") }
    end
  end

  scenario "returning to the document entry modal" do
    within(".modal#start-new-application") do
      click_on("Search for Open Application")
    end

    within(".modal#search-for-submission") do
      click_on("Back to Document Entry")
    end

    within(".modal#start-new-application") do
      expect(page).to have_css("h4", text: "Document Entry")
    end
  end
end
