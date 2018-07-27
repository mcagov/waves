require "rails_helper"

describe "User views finance_payment", type: :feature, js: true do
  scenario "for a related vessel" do
    create(:registered_vessel, reg_no: "SSR99999")

    create(
      :locked_finance_payment,
      part: :part_3,
      application_type: :new_registration,
      vessel_reg_no: "SSR99999")

    visit_fee_entry
    within("tr.vessel") do
      expect(page).to have_text("Official Number: SSR99999")
    end
  end
end
