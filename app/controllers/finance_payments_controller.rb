class FinancePaymentsController < InternalPagesController
  before_action :load_finance_payment

  def show
    respond_to do |format|
      format.pdf do
        @pdf = Pdfs::Processor.run(:payment_receipt, @finance_payment)
        render_pdf(@pdf, @pdf.filename)
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

  private

  def load_finance_payment
    @finance_payment = Payment::FinancePayment.find(params[:id])
  end

  def finance_payment_params
    params.require(:payment_finance_payment).permit(:documents_received)
  end
end
