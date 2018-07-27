require "rails_helper"

describe "User links finance_payment", type: :feature, js: true do
  before do
    vessel_reg_no = create(:registered_vessel).reg_no

    create(
      :submission,
      part: :part_3,
      vessel_reg_no: vessel_reg_no,
      application_type: :change_owner,
      ref_no: "ABC123")

    create(
      :submission,
      part: :part_3,
      vessel_reg_no: create(:registered_vessel).reg_no,
      application_type: :change_vessel,
      ref_no: "FOOBAR")

    create(
      :locked_finance_payment,
      part: :part_3,
      application_type: :new_registration,
      application_ref_no: "ABC123")

    visit_fee_entry
  end

  scenario "to the prompted application" do
    expect(page).to have_css("h1", text: "Fee Received")
    within("#related_submission") { click_on("Link to this Application") }

    application_is_linked
  end

  scenario "to another application" do
    within("#actions") { click_on("Link to another Application") }

    within("#link-application") do
      search_for("foo")
      within("#submissions") { click_on("Link") }
    end

    application_is_linked
  end
end

def application_is_linked
  expect(page).to have_text("payment has been linked")
  expect(page).to have_css("h1", text: "My Tasks")
  expect(Payment::FinancePayment.unattached).to be_empty
end
