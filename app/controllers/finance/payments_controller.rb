class Finance::PaymentsController < InternalPagesController
  before_action :prevent_read_only!
  before_action :load_batch

  def new
    @finance_payment =
      Payment::FinancePayment.new(
        payment_date: Time.zone.today, part: @batch.default_part)
  end

  def show
    @prompt_success = (params[:prompt] == "success")
    @prompt_update = (params[:prompt] == "update")
    finance_payment = Payment::FinancePayment.find(params[:id])
    @finance_payment = Decorators::FinancePayment.new(finance_payment)
  end

  def edit
    @finance_payment = Payment::FinancePayment.find(params[:id])
  end

  def create
    @finance_payment = Payment::FinancePayment.new(finance_payment_params)
    @finance_payment.actioned_by = current_user
    @finance_payment.batch_id = @batch.id

    if @finance_payment.save
      redirect_to finance_batch_payment_path(
        @batch, @finance_payment, prompt: :success)
    else
      render :new
    end
  end

  def update
    @finance_payment = Payment::FinancePayment.find(params[:id])
    @finance_payment.actioned_by = current_user

    if @finance_payment.update_attributes(finance_payment_params)
      flash[:notice] = "Fee entry successfully updated"
      redirect_to finance_batch_payments_path(
        @batch, @finance_payment)
    else
      render :edit
    end
  end

  def index
    @finance_payments =
      @batch.finance_payments.paginate(page: params[:page], per_page: 20)
  end

  protected

  def finance_payment_params
    params.require(:payment_finance_payment).permit(
      :payment_date, :application_ref_no, :part,
      :application_type, :vessel_reg_no, :vessel_name, :payer_name,
      :service_level, :payment_type, :payment_amount, :applicant_is_agent,
      :applicant_name, :applicant_email, :service_level, :documents_received)
  end

  def load_batch
    @batch =
      Decorators::FinanceBatch.new(
        FinanceBatch.includes(finance_payments: [:payment])
                    .find(params[:batch_id]))
  end
end
