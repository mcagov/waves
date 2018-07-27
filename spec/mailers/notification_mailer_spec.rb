require "rails_helper"

RSpec.describe NotificationMailer, type: :mailer do
  describe "test_email" do
    let(:mail) { NotificationMailer.test_email("test@example.com") }

    it "renders the headers" do
      expect(mail.subject).to match(/Message from the MCA/)
      expect(mail.to).to eq(["test@example.com"])
      expect(mail.from).to eq([ENV.fetch("EMAIL_FROM")])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match(/MCA test email/)
    end
  end

  describe "outstanding_declaration" do
    let(:mail) do
      NotificationMailer.outstanding_declaration(
        default_params, "declaration_id",
        "Jolly Roger", "Bob")
    end

    let(:body) { mail.body.encoded }

    it "renders the headers" do
      expect(mail.to).to eq(["test@example.com"])
      expect(mail.from).to eq([ENV.fetch("EMAIL_FROM")])
    end

    it "renders the name" do
      expect(body).to match(/Dear Alice/)
    end

    it "renders the declaration_url" do
      expect(body)
        .to include("/referral/outstanding_declaration/declaration_id")
    end

    it "renders the vessel name" do
      expect(body).to match(/with the name Jolly Roger/)
    end

    it "renders the correspondent name" do
      expect(body).to match(/made by Bob/)
    end
  end

  describe "application_receipt" do
    let(:mail) do
      NotificationMailer.application_receipt(
        default_params, "Jolly Roger", "Ref_no")
    end

    let(:body) { mail.body.encoded }

    it "renders the vessel name" do
      expect(body).to match(/vessel Jolly Roger/)
    end

    it "renders the submission_ref_no" do
      expect(body).to match(/Application Reference No: Ref_no/)
    end
  end

  describe "application_approval templates are present" do
    it "renders for each task type" do
      DeprecableTask.default_task_types.each do |task|
        next unless DeprecableTask.new(task[1]).emails_application_approval?
        mail =
          NotificationMailer.application_approval(
            default_params, "Reg_no", "Bob", task[1], "MV Boat")

        expect(mail.body.encoded).to match(/Dear Alice/)
      end
    end
  end

  describe "application_approval" do
    let(:mail) do
      NotificationMailer.application_approval(
        default_params, "Reg_no",
        "Sally SSR", :new_registration, "My boat", "an_attachment")
    end

    let(:body) { mail.body.encoded }

    it "renders the reg no" do
      expect(body).to match(/your vessel is Reg_no/)
    end

    it "renders the certificate_attached message" do
      expect(body).to match(/attached a copy of your certificate/)
    end

    it "renders the actioned_by signature" do
      expect(body).to match(/Sally SSR/)
    end

    it "renders the phone number" do
      expect(body).to match(/02920 448813/)
    end

    it "renders the survey link" do
      expect(body).to have_link("http://www.smartsurvey.co.uk/s/140065DZMRS/")
    end
  end

  describe "wysiwyg" do
    let(:mail) do
      NotificationMailer.wysiwyg(
        default_params, "Some text", "Sally SSR")
    end

    let(:body) { mail.body.encoded }

    it "renders the body" do
      expect(body).to match(/Some text/)
    end

    it "renders the actioned_by signature" do
      expect(body).to match(/Sally SSR/)
    end

    it "renders the phone number" do
      expect(body).to match(/02920 448813/)
    end
  end

  describe "carving_and_marking_note" do
    let(:mail) do
      NotificationMailer.carving_and_marking_note(
        default_params, 100.0, "Sally SSR", "an_attachment")
    end

    let(:body) { mail.body.encoded }

    it "renders the body" do
      expect(body).to match(/Carving and Marking Note/)
    end
  end

  describe "carving_and_marking_reminder" do
    let(:mail) do
      NotificationMailer.carving_and_marking_reminder(
        default_params, "Jolly Roger", "Ref_no")
    end

    let(:body) { mail.body.encoded }

    it "renders the body" do
      expect(body).to match(/CARVING AND MARKING REMINDER/)
    end
  end

  describe "code_certificate_reminder" do
    let(:mail) do
      NotificationMailer.code_certificate_reminder(
        default_params, "Jolly Roger", "Ref_no")
    end

    let(:body) { mail.body.encoded }

    it "renders the body" do
      expect(body).to match(/CODING EXPIRY/)
    end
  end

  describe "safety_certificate_reminder" do
    let(:mail) do
      NotificationMailer.safety_certificate_reminder(
        default_params, "Jolly Roger", "Ref_no")
    end

    let(:body) { mail.body.encoded }

    it "renders the body" do
      expect(body).to match(/SAFETY EXPIRY/)
    end
  end

  describe "renewal_reminder" do
    let(:mail) do
      NotificationMailer.renewal_reminder(
        default_params, "Jolly Roger", "3/1/2017", "an_attachment")
    end

    it "attaches the renewal letter" do
      attachment = mail.attachments[0]
      expect(attachment.filename).to eq("renewal_letter.pdf")
    end
  end
end

def default_params
  {
    subject: "subject",
    to: "test@example.com",
    name: "Alice",
    department: Department.new(:part_3, ""),
  }
end

def declaration_text
  "until all declarations have been received"
end
