class Decorators::FinancePayment < SimpleDelegator
  include ActionView::Helpers::NumberHelper

  def initialize(finance_payment)
    @finance_payment = finance_payment
    super
  end

  def part_description
    Activity.new(part)
  end

  def application_type_description
    ApplicationType.new(application_type).description
  end

  def payment_type_description
    Payment::FinancePayment::PAYMENT_TYPES.find do |t|
      t[1] == payment_type.to_sym
    end[0] if payment_type
  end

  def assigned_application_ref_no
    locked? ? submission.ref_no : application_ref_no
  end

  def refund?
    payment_amount < 0
  end

  def payment?
    !refund
  end

  def page_heading
    refund? ? "Refund Due" : "Fee Received"
  end
end
