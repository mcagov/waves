FactoryGirl.define do
  factory :finance_payment, class: "Payment::FinancePayment" do
    payment_date    { 1.day.ago }
    part            :part_3
    application_type :new_registration
    payment_amount  25.00
    batch           { build(:finance_batch) }
    payment_type    :bacs
    vessel_name     "MY BOAT"
    applicant_name  "ALICE"
    applicant_email "alice@example.com"
    service_level   "premium"
    documents_received "Excel file"
    applicant_is_agent true
  end

  factory :locked_finance_payment, parent: :finance_payment do
    after(:create) do |finance_payment|
      finance_payment.lock!
    end
  end
end
