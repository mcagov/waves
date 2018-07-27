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
        if submission.electronic_delivery?
          # Note: ensure that the submission state has
          # transitioned before the notification is delivered.
          # This will ensure that there is a registration object
          # that can be associated with the submission
          submission.approve_electronic_delivery!
          create_application_approval_notification
        else
          create_application_receipt_notification
        end
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
          submission, nil,
          DeprecableTask.new(submission.task).print_job_templates.first)
      end
    end
  end
end
