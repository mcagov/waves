class FinancePaymentsController < InternalPagesController
  before_action :load_finance_payment, only: [:show, :update]

  def show
    respond_to do |format|
      format.pdf do
        @pdf = Pdfs::Processor.run(:payment_receipt, @finance_payment)
        render_pdf(@pdf, @pdf.filename)
      end
      format.html do
        load_helpers
      end
    end
  end

  def update
    @finance_payment.update_attributes(finance_payment_params)

    respond_to do |format|
      format.js do
        @finance_payment = Decorators::FinancePayment.new(@finance_payment)
      end
    end
  end

  def unattached_payments
    @finance_payments = unattached_finance_payments.payments
    @heading = "Fees Received"
    render :index
  end

  def unattached_refunds
    @finance_payments = unattached_finance_payments.refunds
    @heading = "Refunds Due"
    render :index
  end

  private

  def load_finance_payment
    @finance_payment = Payment::FinancePayment.find(params[:id])
  end

  def finance_payment_params
    params.require(:payment_finance_payment).permit(:documents_received)
  end

  def unattached_finance_payments
    Payment::FinancePayment
      .in_part(current_activity.part)
      .paginate(page: params[:page], per_page: 50)
      .unattached
  end

  def load_helpers
    @submission = @finance_payment.submission
    @related_submission = @finance_payment.related_submission
    @related_vessel = @finance_payment.related_vessel
  end
end
