class Pdfs::Processor
  class << self
    def run(template, printable_items, mode = :printable)
      Pdfs::Processor.new(template, printable_items, mode).perform
    end
  end

  def initialize(template, printable_items, mode = :printable)
    @template = template
    @printable_items = printable_items
    @part = Array(@printable_items).first.part.to_sym
    @mode = mode
  end

  def perform
    send(@template)
  end

  private

  def registration_certificate
    case @part
    when :part_1
      Pdfs::Part1::Certificate.new(@printable_items, @mode)
    when :part_2
      Pdfs::Part2::Certificate.new(@printable_items, @mode)
    when :part_3
      Pdfs::Part3::Certificate.new(@printable_items, @mode)
    when :part_4
      Pdfs::Part4::Certificate.new(@printable_items, @mode)
    end
  end

  def duplicate_registration_certificate
    case @part
    when :part_1
      Pdfs::Part1::Certificate.new(@printable_items, @mode, duplicate: true)
    when :part_2
      Pdfs::Part2::Certificate.new(@printable_items, @mode, duplicate: true)
    when :part_3
      Pdfs::Part3::Certificate.new(@printable_items, @mode, duplicate: true)
    when :part_4
      Pdfs::Part4::Certificate.new(@printable_items, @mode, duplicate: true)
    end
  end

  def cover_letter
    case @part
    when :part_3
      Pdfs::Part3::CoverLetter.new(@printable_items)
    else
      Pdfs::Extended::CoverLetter.new(@printable_items)
    end
  end

  def current_transcript
    case @part
    when :part_1
      Pdfs::Part1::Transcript.new(@printable_items, @mode)
    when :part_2
      Pdfs::Part2::Transcript.new(@printable_items, @mode)
    when :part_3
      Pdfs::Part3::Transcript.new(@printable_items, @mode)
    when :part_4
      Pdfs::Part4::Transcript.new(@printable_items, @mode)
    end
  end

  def historic_transcript
    case @part
    when :part_1
      Pdfs::Part1::HistoricTranscript.new(@printable_items, @mode)
    when :part_2
      Pdfs::Part2::HistoricTranscript.new(@printable_items, @mode)
    when :part_3
      Pdfs::Part3::HistoricTranscript.new(@printable_items, @mode)
    when :part_4
      Pdfs::Part4::HistoricTranscript.new(@printable_items, @mode)
    end
  end

  def carving_and_marking
    Pdfs::CarvingAndMarking.new(@printable_items, @mode)
  end

  def csr_form
    Pdfs::CsrForm.new(@printable_items, @mode)
  end

  def provisional_certificate
    Pdfs::ProvisionalCertificate.new(@printable_items, @mode)
  end

  def termination_notice
    Pdfs::TerminationNotice.new(@printable_items, @mode)
  end

  def section_notice
    Pdfs::SectionNotice.new(@printable_items, @mode)
  end

  def renewal_reminder_letter
    case @part
    when :part_1
      Pdfs::Part1::RenewalReminderLetter.new(@printable_items, @mode)
    when :part_2
      Pdfs::Part2::RenewalReminderLetter.new(@printable_items, @mode)
    when :part_3
      Pdfs::Part3::RenewalReminderLetter.new(@printable_items, @mode)
    when :part_4
      Pdfs::Part4::RenewalReminderLetter.new(@printable_items, @mode)
    end
  end

  def mortgagee_reminder_letter
    Pdfs::MortgageeReminderLetter.new(@printable_items, @mode)
  end

  def forced_closure
    Pdfs::ForcedClosure.new(@printable_items)
  end

  def payment_receipt
    Pdfs::PaymentReceipt.new(@printable_items)
  end
end
