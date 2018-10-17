class Pdfs::Part3::CertificateWriter < Pdfs::CertificateWriter
  private

  def write_attachable
    @pdf.start_new_page
    @pdf.image page_1_template, scale: 0.48
    watermark
    registration_details
    @pdf.start_new_page
    @pdf.image page_2_template, scale: 0.48
    watermark
  end

  def write_printable
    @pdf.start_new_page
    registration_details
  end

  def page_1_template
    "#{Rails.root}/public/pdf_images/part_3_front.png"
  end

  def page_2_template
    "#{Rails.root}/public/pdf_images/part_3_rear.png"
  end

  def registration_details # rubocop:disable Metrics/MethodLength
    draw_value(@registration.registered_until, at: [57, 300])
    draw_value @vessel[:reg_no], at: [182, 300]
    draw_label_value "Description",
                     @vessel.vessel_type.try(:upcase), at: [34, 265]
    draw_label_value "Overall Length",
                     format_decimal(@vessel.length_in_meters), at: [34, 250]
    draw_label_value "Number of Hulls", @vessel.number_of_hulls, at: [34, 235]
    draw_label_value "Name of Ship", @vessel.name, at: [34, 220]
    draw_label_value "Hull ID Number", @vessel.hin, at: [34, 205]

    owners
    @pdf.draw_text @registration.registered_at, at: [60, 27]
  end

  def owners
    if @owners.length > 6
      @pdf.font("Helvetica-Oblique", size: 9)
      @pdf.text_box(@owners.map(&:name).join("; "), width: 240, at: [30, 170])
    else
      offset = 0
      @owners.each do |owner|
        draw_value owner.name, at: [40, 157 - offset]
        offset += 12
      end
    end
  end

  def draw_label_value(label, text, opts)
    default_label_font
    @pdf.text_box("#{label} :", opts.merge(align: :right, width: 80))
    default_value_font
    @pdf.draw_text(text, at: [opts[:at][0] + 85, opts[:at][1] - 7])
  end

  def draw_value(text, opts = {})
    default_value_font
    @pdf.draw_text(text, opts)
  end

  def watermark
    @pdf.transparent(0.1) do
      @pdf.draw_text "COPY OF ORIGINAL", at: [60, 10], rotate: 60, size: 44
    end
  end
end
