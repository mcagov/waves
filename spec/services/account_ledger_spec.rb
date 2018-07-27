require "rails_helper"

describe AccountLedger do
  let(:account_ledger) { described_class.new(submission) }

  context "#payment_status" do
    subject { account_ledger.payment_status }

    context "not_applicable" do
      let(:submission) { build(:submission) }

      it { expect(subject).to eq(:not_applicable) }
    end

    context "unpaid" do
      let(:submission) { create(:submission_task).submission }

      it { expect(subject).to eq(:unpaid) }
    end

    context "paid" do
      let(:submission) do
        submission = create(:submission_task).submission
        create(:payment, submission: submission, amount: 2500)
        submission.reload
      end
      it { expect(subject).to eq(:paid) }
    end

    context "part_paid" do
      let(:submission) do
        submission = create(:submission_task).submission
        create(:payment, submission: submission, amount: 50)
        submission.reload
      end

      it { expect(subject).to eq(:part_paid) }
    end
  end

  context "#awaiting_payment?" do
    let(:submission) { build(:submission) }

    before do
      allow(account_ledger)
        .to receive(:payment_status)
        .and_return(payment_status)
    end

    subject { account_ledger.awaiting_payment? }

    context "not_applicable" do
      let(:payment_status) { :not_applicable }

      it { expect(subject).to be_falsey }
    end

    context "paid" do
      let(:payment_status) { :paid }

      it { expect(subject).to be_falsey }
    end

    context "unpaid" do
      let(:payment_status) { :unpaid }

      it { expect(subject).to be_truthy }
    end

    context "part_paid" do
      let(:payment_status) { :part_paid }

      it { expect(subject).to be_truthy }
    end
  end

  context "#ui_color" do
    let(:submission) { build(:submission) }

    before do
      allow(account_ledger)
        .to receive(:payment_status)
        .and_return(payment_status)
    end

    subject { account_ledger.ui_color }

    context "not_applicable" do
      let(:payment_status) { :not_applicable }

      it { expect(subject).to eq("default") }
    end

    context "paid" do
      let(:payment_status) { :paid }

      it { expect(subject).to eq("success") }
    end

    context "unpaid" do
      let(:payment_status) { :unpaid }

      it { expect(subject).to eq("danger") }
    end

    context "part_paid" do
      let(:payment_status) { :part_paid }

      it { expect(subject).to eq("info") }
    end
  end

  context "#payment_due" do
    subject { account_ledger.payment_due }

    context "by default (no line_items)" do
      let!(:submission) { build(:submission) }

      it { expect(subject).to eq(0.00) }
    end

    context "with a chargeable task" do
      let!(:submission) { create(:submission_task).submission }

      it { expect(subject).to eq(2500) }
    end
  end

  context "#balance" do
    subject { account_ledger.balance }

    context "by default (no line_items)" do
      let!(:submission) { build(:submission) }

      it { expect(subject).to eq(0.00) }
    end

    context "with a chargeable task and one (over) payment" do
      let!(:submission) do
        submission = create(:submission_task).submission
        create(:payment, submission: submission, amount: 2000)
        submission.reload
      end

      it { expect(subject).to eq(-500) }
    end
  end
end
