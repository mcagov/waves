class FinancePayments::SubmissionsController < InternalPagesController
  include InitNewSubmission
  before_action :load_finance_payment

  def new
    @submission = @finance_payment.submission
  end

  def create
    init_new_submission

    if @submission.save
      assign_payment
      send_application_receipt_email
      flash[:notice] ||=
        "The application has been saved to the unclaimed tasks queue"
      redirect_to tasks_my_tasks_path
    else
      render :new
    end
  end

  protected

  def submission_params
    return {} unless params[:submission]
    params.require(:submission).permit(
      :part, :application_type, :received_at, :applicant_name,
      :applicant_is_agent, :applicant_email, :vessel_reg_no,
      :documents_received,
      vessel: Submission::Vessel::ATTRIBUTES
    )
  end

  def assign_payment
    @finance_payment.payment.update_attribute(:submission_id, @submission.id)
  end

  def load_finance_payment
    @finance_payment = Payment::FinancePayment.find(params[:finance_payment_id])
  end
end
