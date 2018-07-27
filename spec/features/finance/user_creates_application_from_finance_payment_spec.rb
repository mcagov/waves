require "rails_helper"

describe "User creates application from finance payment",
         type: :feature, js: true do
  before do
    create(:locked_finance_payment)
    visit_fee_entry
    click_on(create_new_application_link)
  end

  scenario "in general" do
    click_on("Save")
    application_is_saved
  end

  scenario "rendering the :new template after an error" do
    select("Re-Registration", from: "Application Type")
    click_on("Save")

    select("New Registration", from: "Application Type")
    click_on("Save")

    application_is_saved
  end
end

def create_new_application_link
  "Create New Application"
end

def application_is_saved
  expect(page).to have_text("application has been saved")
  expect(page).to have_css("h1", text: "My Tasks")
  expect(Payment::FinancePayment.unattached).to be_empty
end
