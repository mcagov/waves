require "rails_helper"

describe Payment::FinancePayment do
  context "for a new application" do
    context ".create" do
      let!(:finance_payment) do
        described_class.create(
          payment_date: Time.zone.today,
          part: :part_1,
          application_type: :unknown,
          vessel_reg_no: "",
          payment_type: :cash,
          payment_amount: "25",
          actioned_by: create(:user),
          applicant_name: "Bob",
          applicant_email: "bob@example.com",
          applicant_is_agent: true,
          application_ref_no: "ABC123",
          service_level: "premium",
          documents_received: "some files"
        )
      end

      it "is actioned_by a user" do
        expect(finance_payment.actioned_by).to be_present
      end

      it "is not locked" do
        expect(finance_payment).not_to be_locked
      end

      context "#lock!" do
        before { finance_payment.lock! }

        it "creates the payment with the expected amount" do
          expect(finance_payment.payment.amount).to eq(2500)
        end
      end
    end
  end

  context "for a registered (when vessel_reg_no is valid)" do
    let(:registered_vessel) { create(:registered_vessel) }

    let!(:finance_payment) do
      described_class.new(
        payment_date: Time.zone.today,
        part: registered_vessel.part,
        vessel_reg_no: registered_vessel.reg_no,
        payment_amount: "25",
        actioned_by: create(:user),
        application_type: :change_vessel
      )
    end

    it { expect(finance_payment).to be_valid }
  end

  context "with invalid params" do
    let!(:finance_payment) do
      described_class.create(
        part: :part_1,
        payment_amount: "bob",
        application_type: nil,
        vessel_reg_no: "nonexistent"
      )
    end

    it { expect(finance_payment.errors).to include(:payment_date) }
    it { expect(finance_payment.errors).to include(:payment_amount) }
    it { expect(finance_payment.errors).to include(:application_type) }
    it { expect(finance_payment.errors).to include(:vessel_reg_no) }
  end

  context "#submission" do
    let(:finance_payment) { create(:locked_finance_payment) }
    subject { finance_payment.submission }

    context "when the payment is attached to a submission" do
      let!(:submission) { create(:submission) }
      before do
        finance_payment.payment.update_attribute(:submission_id, submission.id)
      end

      it "assigns the submission" do
        expect(subject).to eq(submission)
      end

      it { expect(subject).to be_persisted }
    end

    context "when the payment is not attached to a submission" do
      it { expect(subject.part).to eq("part_3") }
      it { expect(subject.application_type). to eq("new_registration") }
      it { expect(subject.vessel_name). to eq("MY BOAT") }
      it { expect(subject.applicant_name). to eq("ALICE") }
      it { expect(subject.applicant_email). to eq("alice@example.com") }
      it { expect(subject.applicant_is_agent).to be_truthy }
      it { expect(subject.documents_received).to eq("Excel file") }

      it do
        expect(subject.received_at.to_date).to eq(finance_payment.payment_date)
      end

      it { expect(subject).to be_new_record }
    end

    context "when the payment is for a registered vessel" do
      let(:registered_vessel) { create(:registered_vessel) }

      before do
        finance_payment
          .update_attribute(:vessel_reg_no, registered_vessel.reg_no)
      end

      it { expect(subject.vessel_reg_no).to eq(registered_vessel.reg_no) }
    end
  end

  context "#related_submission" do
    let!(:submission) { create(:unassigned_change_vessel_submission) }
    let(:finance_payment) { create(:locked_finance_payment, params) }

    subject { finance_payment.related_submission }

    context "with a valid application_ref_no" do
      let(:params) { { application_ref_no: submission.ref_no } }

      it { expect(subject).to eq(submission) }
    end

    context "with an invalid application_ref_no" do
      let(:params) { { application_ref_no: "foo" } }

      it { expect(subject).to be_nil }
    end

    context "with a valid vessel_reg_no" do
      let(:params) { { vessel_reg_no: submission.vessel_reg_no } }

      it { expect(subject).to eq(submission) }
    end
  end
end
