require "rails_helper"

feature "User edits Delivery Address details", type: :feature, js: true do
  scenario "in general" do
    visit_assigned_submission

    click_on("Payment")
    within("#delivery_address") do
      click_on("BOB DOLE, 11 DOWNING ST, WHITEHALL")

      within(".address-name") { click_on("BOB DOLE") }
      find(".editable-input input").set("John Doe")
      first(".editable-submit").click
      expect(page).to have_css(".address-name", text: "John Doe")

      within(".address-country") { click_on("UNITED KINGDOM") }
      find(".editable-input select").select("SPAIN")
      first(".editable-submit").click
      expect(page).to have_css(".address-country", text: "SPAIN")

      expect(page).to have_css(
        "a#inline_delivery_address",
        text: "ohn Doe, 11 DOWNING ST, WHITEHALL, CARDIFF, SPAIN, W1 1AF")
    end
  end
end
