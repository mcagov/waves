class AccountLedger
  def initialize(submission)
    @submission = submission
  end

  def ui_color
    case payment_status
    when :not_applicable then "default"
    when :unpaid then "danger"
    when :part_paid then "info"
    when :paid then "success"
    end
  end

  def payment_status
    return :not_applicable if payment_due.zero?
    return :unpaid if payment_received.zero?
    return :paid if balance >= 0
    :part_paid
  end

  def payment_due
    @payment_due ||= @submission.tasks.map(&:price).inject(:+) || 0
  end

  def payment_received
    @payment_received ||=
      @submission
      .payments.map { |payment| payment.amount.to_i }
      .inject(:+) || 0
  end

  def awaiting_payment?
    ![:not_applicable, :paid].include?(payment_status)
  end

  def balance
    payment_received - payment_due
  end
end
