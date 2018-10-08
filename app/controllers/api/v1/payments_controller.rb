module Api
  module V1
    class PaymentsController < ApiController
      def create
        @payment =
          Builders::WorldPayPaymentBuilder.create(create_payment_params)

        if submission && @payment.valid?
          process_payment_receipt
          render json: @payment, status: :created
        else
          render json: @payment, status: :unprocessable_entity,
                 serializer: ActiveModel::Serializer::ErrorSerializer
        end
      end

      private

      def create_payment_params
        data = params.require("data")
        data.require(:attributes).permit(
          :submission_id, :wp_amount, :customer_ip, :wp_order_code)
      end

      def process_payment_receipt
        create_application_receipt_notification
      end

      def submission
        @submission ||= @payment.submission
      end

      def create_application_receipt_notification
        Notification::ApplicationReceipt.create(
          notifiable: submission,
          recipient_name: submission.applicant_name,
          recipient_email: submission.applicant_email)
      end

      def create_application_approval_notification
        Builders::NotificationBuilder.application_approval(
          submission, nil, :print_template)
      end
    end
  end
end
