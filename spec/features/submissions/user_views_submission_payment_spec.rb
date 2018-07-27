require "rails_helper"

feature "User views submission payment", type: :feature, js: true do
  before do
    submission = create(:submission_task).submission
    create(:payment, submission: submission) # World Pay
    create(
      :payment,
      submission: submission,
      amount: 3000,
      remittance: build(:locked_finance_payment, payment_amount: 30))

    login_to_part_3
    visit submission_path(submission)
    click_link("Payments")
  end

  scenario "World Pay" do
    within(".world_pay") do
      expect(page).to have_text("£25.00")
    end
  end

  scenario "Finance Payment" do
    within(".finance_payment") do
      find(:css, ".fa-info").trigger("click")
    end

    within(".modal.fade.in") do
      expect(page).to have_text("£30.00")
    end
  end
end
