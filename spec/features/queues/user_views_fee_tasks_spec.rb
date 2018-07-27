require "rails_helper"

feature "User views fee task lists", type: :feature, js: true do
  before do
    create(:locked_finance_payment, payment_amount: payment_amount)
    login_to_part_3
    visit "/finance_payments/unattached_payments"
  end

  context "fees received" do
    let(:payment_amount) { 2500 }

    scenario "in general" do
      page.all("table#submissions") do
        within("tr[1]") do
          expect(page).to have_css(".payment", text: "£25.00")
        end
      end
    end
  end

  context "refunds due" do
    let(:payment_amount) { -1099 }

    scenario "in general" do
      click_link("Refunds Due")

      page.all("table#submissions") do
        within("tr[1]") do
          expect(page).to have_css(".payment", text: "£-10.99")
        end
      end
    end
  end
end
