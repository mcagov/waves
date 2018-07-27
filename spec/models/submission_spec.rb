require "rails_helper"

describe Submission, type: :model do
  context "in general" do
    let!(:submission) { create(:incomplete_submission) }

    it "gets the vessel_info" do
      expect(submission.vessel).to be_a(Submission::Vessel)
    end

    it "has a state: incomplete" do
      expect(submission).to be_incomplete
    end

    it "gets the delivery_address" do
      expect(submission.delivery_address.country).to eq("UNITED KINGDOM")
    end

    context "changing the registered_vessel_id" do
      before do
        expect(Builders::SubmissionBuilder)
          .to receive(:build_defaults)
          .with(submission)
      end

      it "invokes the SubmissionBuilder#build_defaults" do
        submission.registered_vessel_id = create(:registered_vessel).id
        submission.save
      end
    end
  end

  context "#electronic_delivery?" do
    let(:submission) { build(:submission, changeset: electronic_delivery) }

    subject { submission.electronic_delivery? }

    context "when electronic_delivery is true" do
      let(:electronic_delivery) { { "electronic_delivery" => true } }

      it { expect(subject).to be_truthy }
    end

    context "when electronic_delivery is false" do
      let(:electronic_delivery) { { "electronic_delivery" => false } }

      it { expect(subject).to be_falsey }
    end

    context "when the electronic_delivery has not been defined" do
      let(:electronic_delivery) { {} }

      it { expect(subject).to be_falsey }
    end
  end

  context ".vessel_reg_no =" do
    let!(:registered_vessel) { create(:registered_vessel, part: vessel_part) }
    let(:submission) { create(:incomplete_submission, part: :part_1) }

    before { submission.vessel_reg_no = registered_vessel.reg_no }

    context "for a part_1 submission and a part_1 registered_vessel" do
      let(:vessel_part) { :part_1 }

      it { expect(submission.registered_vessel).to eq(registered_vessel) }
    end

    context "for a part_2 submission and a part_1 registered_vessel" do
      let(:vessel_part) { :part_2 }

      it { expect(submission.registered_vessel).to be_nil }
    end
  end

  context "#vessel_name" do
    subject { submission.vessel_name }

    context "with a registered_vessel" do
      let(:submission) { build(:unassigned_change_vessel_submission) }

      it { expect(subject).to eq(submission.registered_vessel.name) }
    end

    context "with a vessel name in the changeset" do
      let(:submission) { build(:submission) }

      it { expect(subject).to eq(submission.vessel.name) }
    end

    context "with a vessel name in a finance payment entry" do
      let(:submission) do
        create(:locked_finance_payment, vessel_name: "FP BOAT")
      end

      it { expect(subject).to eq("FP BOAT") }
    end

    context "with no vessel name" do
      let(:submission) { Submission.new }

      it { expect(subject).to eq("UNKNOWN") }
    end
  end

  context ".registered_vessel_exists" do
    let!(:submission) { build(:submission) }

    before do
      allow(Policies::Actions)
        .to receive(:registered_vessel_required?)
        .with(submission)
        .and_return(registered_vessel_required_policy)

      submission.save
    end

    context "when the registered_vessel_required? policy returns true" do
      let(:registered_vessel_required_policy) { true }

      it { expect(submission.errors).to include(:vessel_reg_no) }

      context "and the submission has a registered_vessel" do
        before do
          submission.vessel_reg_no = create(:registered_vessel).reg_no
        end

        it { expect(submission).to be_valid }
      end
    end

    context "when the registered_vessel_required? policy returns false" do
      let(:registered_vessel_required_policy) { false }

      it { expect(submission).to be_valid }
    end
  end

  context ".referred_until_expired" do
    let!(:submission) { create(:submission, referred_until: referred_until) }
    let(:submissions) { Submission.referred_until_expired }

    before do
      Timecop.travel(Time.new(2016, 6, 18))
    end

    after do
      Timecop.return
    end

    context "tomorrow" do
      let(:referred_until) { Time.new(2016, 6, 19) }
      it { expect(submissions).to be_empty }
    end

    context "today" do
      let(:referred_until) { Time.new(2016, 6, 18) }
      it { expect(submissions.length).to eq(1) }
    end

    context "yesterday" do
      let(:referred_until) { Time.new(2016, 6, 17) }
      it { expect(submissions.length).to eq(1) }
    end

    context "nil" do
      let(:referred_until) { nil }
      it { expect(submissions).to be_empty }
    end
  end

  context "state machine transitions" do
    context "to unassigned" do
      let!(:submission) { create(:incomplete_submission) }
      let!(:payment) { Payment.create(amount: 100, submission: submission) }

      before do
        allow(Policies::Actions)
          .to receive(:actionable?)
          .with(submission)
          .and_return(true)
      end

      it { submission.touch }
    end

    context "to assigned" do
      let!(:submission) { create(:unassigned_submission) }
      let!(:bob) { create(:user) }

      before { submission.claimed!(bob) }

      it { expect(submission.claimant).to eq(bob) }
    end

    context "from assigned to unassigned" do
      let!(:submission) { create(:assigned_submission) }
      let!(:bob) { create(:user) }

      before { submission.unclaimed! }

      it { expect(submission.claimant).to be_nil }
    end

    context "from assigned to referred" do
      let!(:submission) { create(:assigned_submission) }

      before { submission.referred! }

      it { expect(submission.claimant).to be_nil }
    end

    context "from referred to unassigned" do
      let!(:submission) { create(:referred_submission) }

      before do
        submission.unreferred!
      end

      it { expect(submission.claimant).to be_nil }
    end

    context "from assigned to completed" do
      let!(:submission) { create(:assigned_submission) }
      let!(:bob) { create(:user) }

      before { submission.approved! }

      it { expect(submission.claimant).to be_present }
    end

    context "#approve_electronic_delivery" do
      let!(:submission) { create(:unassigned_submission) }

      before { submission.approve_electronic_delivery! }

      it { expect(submission.claimant).to be_nil }
      it { expect(submission).to be_completed }
    end

    context "#cancelled (cleaning up the name_approval)" do
      let(:name_approval) { create(:submission_name_approval) }

      before { name_approval.submission.cancelled! }

      it "sets the name_approval#cancelled_at" do
        expect(name_approval.cancelled_at).to be_present
      end
    end

    context "#cancelled (cleaning up the registered_vessel)" do
      let!(:submission) do
        create(:assigned_submission, registered_vessel: vessel)
      end

      before do
        submission.cancelled!
        submission.reload
      end

      context "with the vessel's registration is pending" do
        let!(:vessel) { create(:pending_vessel) }

        it "removes the registered_vessel" do
          expect(submission.registered_vessel).to be_nil
        end
      end

      context "with the vessel is already registered" do
        let!(:vessel) { create(:registered_vessel) }

        it "retains the registered_vessel" do
          expect(submission.registered_vessel).to eq(vessel)
        end
      end
    end
  end
end
