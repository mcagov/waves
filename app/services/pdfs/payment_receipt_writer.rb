class Pdfs::PaymentReceiptWriter
  include Pdfs::Stationary
  include ActionView::Helpers::NumberHelper
  include ApplicationHelper

  def initialize(finance_payment, pdf)
    @finance_payment = Decorators::FinancePayment.new(finance_payment)
    @pdf = pdf
  end

  # rubocop:disable all
  def write
    @pdf.start_new_page
    @skip_date_and_ref = true
    init_stationary(Time.zone.today)

    @pdf.font("Helvetica-Bold", size: 16)
    @pdf.text_box "Receipt of Fee Received",
                  at: [0, 634], width: 590, height: 200, align: :center

    @pdf.font("Helvetica")
    @pdf.move_down 250
    @pdf.indent 100 do
      @pdf.table(payment_receipt_table_data,
                 width: 400,
                 column_widths: [160, 240],
                 cell_style: { size: 11, padding: 6, height: 34, border_width: 0 }) do
        column(0).style({font: "Helvetica-Bold"})
        column(1).style({font: "Helvetica"})
      end
    end
    @pdf
  end

  def payment_receipt_table_data
    [
      ["Fee Receipt Date", @finance_payment.payment_date],
      ["Application Reference No.", @finance_payment.application_ref_no],
      ["Part of the Register", @finance_payment.part_description.to_s],
      ["Application Type", @finance_payment.application_type_description],
      ["Official Number", @finance_payment.vessel_reg_no],
      ["Vessel Name", @finance_payment.vessel_name],
      ["Payer Name", @finance_payment.payer_name],
      ["Payment Type", @finance_payment.payment_type_description],
      ["Fee Amount", formatted_amount(@finance_payment.payment_amount)],
      ["Applicant Name", @finance_payment.applicant_name],
      ["Applicant`s Email Address", @finance_payment.applicant_email],
      ["Service Level", @finance_payment.service_level.try(:titleize)],
    ]
  end
  # rubocop:enable all
end
