require "rails_helper"

describe "User prints payment receipt", type: :feature, js: true do
  before do
    create(:locked_finance_payment)

    visit_fee_entry
  end

  scenario "in general" do
    expect(page).to have_link(
      "Print Payment Receipt",
      href: finance_payment_path(Payment::FinancePayment.last, format: :pdf))

    pdf_window = window_opened_by do
      click_on("Print Payment Receipt")
    end

    within_window(pdf_window) do
      expect(page).to have_text("%PDF")
    end
  end
end
