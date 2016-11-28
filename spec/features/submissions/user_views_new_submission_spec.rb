require "rails_helper"

feature "User views new submission", type: :feature, js: true do
  before do
    visit_unassigned_submission
  end

  scenario "in general" do
    within("h1") do
      expect(page).to have_content("New Registration ID: ")
    end

    expect(page).to have_css(".active-register", text: "Active: Part III")

    expect(page)
      .not_to have_css(
        "a", text: "Register Vessel & Issue Certificate of Registry")

    click_link("Payment")
    within("#payment") do
      expect(page).to have_text("Amount £ 25.00")
    end

    click_link("History")
    within("#history") do
      expect(page).to have_text("Application started")
    end
  end
end