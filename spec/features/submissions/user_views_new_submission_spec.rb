require "rails_helper"

feature "User views new submission", type: :feature, js: true do
  before do
    visit_claimed_task
  end

  scenario "in general" do
    within("h1") do
      expect(page).to have_content(/ID: .* Demo Service/)
    end

    expect(page).to have_css(".active-register", text: "Active: Part III")

    expect(page)
      .not_to have_css(
        "a", text: "Register Vessel & Issue Certificate of Registry")

    click_link("Payment")
    within("#payment") do
      expect(page).to have_text("£25.00")
    end

    click_link("History")
    within("#history") do
      expect(page).to have_text("Application started")
    end

    click_link("Agent")
    within("#agent") do
      expect(page).to have_css(".agent-name", text: "Annabel Agent")
      expect(page).to have_css(".agent-email", text: "agent@example.com")
      expect(page).to have_css(".agent-phone_number", text: "1-800-AGENT")
    end
  end
end
