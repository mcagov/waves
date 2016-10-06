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
        "Vessel Registration Owner Declaration Required",
        "test@example.com", "Alice", "declaration_id",
        "Jolly Roger", "Bob")
    end

    let(:body) { mail.body.encoded }

    it "renders the headers" do
      expect(mail.subject)
        .to match(/Vessel Registration Owner Declaration Required/)
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

    it "renders the applicant name" do
      expect(body).to match(/made by Bob/)
    end
  end

  describe "application_receipt" do
    let(:mail) do
      NotificationMailer.application_receipt(
        "subject", "test@example.com", "Alice", "Jolly Roger",
        "WP_code", "Ref_no")
    end

    let(:body) { mail.body.encoded }

    it "renders the vessel name" do
      expect(body).to match(/vessel Jolly Roger/)
    end

    it "renders the world_pay_transaction_no" do
      expect(body).to match(/Merchant Cart ID: WP_code/)
    end

    it "renders the submission_ref_no" do
      expect(body).to match(/Application Reference No: Ref_no/)
    end
  end

  describe "application_approval" do
    let(:mail) do
      NotificationMailer.application_approval(
        "subject", "test@example.com", "Alice", "Reg_no")
    end

    let(:body) { mail.body.encoded }

    it "renders the reg no" do
      expect(body).to match(/your vessel is Reg_no/)
    end
  end

  describe "wysiwyg" do
    let(:mail) do
      NotificationMailer.wysiwyg(
        "subject", "test@example.com", "Alice", "Some text")
    end

    let(:body) { mail.body.encoded }

    it "renders the body" do
      expect(body).to match(/Some text/)
    end
  end
end
