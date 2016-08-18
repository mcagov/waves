require "rails_helper"

describe Submission, type: :model do

  context "in general" do
    let!(:submission) { create_submission! }

    it "gets the vessel_info" do
      expect(submission.vessel_info).to eq(submission.user_input[:vessel_info])
    end

    it "get two owners" do
      expect(submission.owners.length).to eql(2)
    end
  end

  context "#paid?" do
    context "has a status: :paid" do
      subject { build(:paid_submission).paid? }
      it { expect(subject).to be_truthy }
    end

    context "has a status: :foo" do
      subject { build(:submission).paid? }
      it { expect(subject).to be_falsey }
    end
  end

  context "declared_by?" do
    let!(:submission) { create_submission! }

    it "was declared_by by the first owner" do
      expect(submission).to be_declared_by(submission.owners.first)
    end

    it "was not declared_by by the second owner" do
      expect(submission).not_to be_declared_by(submission.owners.last)
    end
  end

  context "#vessel_type" do
    let(:submission)  do
      build(:submission, changeset: { vessel_info: vessel_info })
    end

    subject { submission.vessel_type }

    context "with the vessel_type field" do
      let(:vessel_info) { {vessel_type: "Barge"} }
      it { expect(subject).to eq("Barge") }
    end

    context "using vessel_type_other field" do
      let(:vessel_info) { {vessel_type: "", vessel_type_other: "Zebra"} }
      it { expect(subject).to eq("Zebra") }
    end
  end

  context "#target_date" do
    let!(:submission) { create_submission! }
    let!(:payment) { create(:payment, submission_id: submission.id, wp_amount: wp_amount)}

    subject { submission.target_date.to_date }

    context "standard service" do
      let(:wp_amount) { 2500 }
      it { expect(subject).to eq(20.days.from_now.to_date) }
    end

    context "premium service" do
      let(:wp_amount) { 7500 }
      it { expect(subject).to eq(5.days.from_now.to_date) }
    end
  end
end