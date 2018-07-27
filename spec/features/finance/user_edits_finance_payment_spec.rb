require "rails_helper"

describe "User edits finance payment", type: :feature, js: true do
  before do
    create(:locked_finance_payment)
    visit_fee_entry
  end

  scenario "in general" do
    click_on("Edit Documents Received")
    fill_in("Documents Received", with: "Excel file, C&M")
    click_button("Save")

    expect(page).to have_css("#documents-received", text: "Excel file, C&M")
  end
end
