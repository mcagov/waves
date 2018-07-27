require "rails_helper"

describe Policies::Actions do
  context "#readonly" do
    let!(:user) { create(:user) }
    subject { described_class.readonly?(submission, user) }

    context "when the submission is assigned to the user" do
      let(:submission) { create(:assigned_submission) }
      let(:user) { submission.claimant }
      it { expect(subject).to be_falsey }
    end

    context "when the submission is assigned to a different user" do
      let(:submission) { build(:assigned_submission) }
      it { expect(subject).to be_truthy }
    end

    context "when the submission is unassigned" do
      let(:submission) { build(:unassigned_submission) }
      it { expect(subject).to be_truthy }
    end

    context "when the submission is completed" do
      let(:submission) { build(:completed_submission) }
      it { expect(subject).to be_truthy }
    end
  end

  context "#registered_vessel_required?" do
    let(:submission) { build(:submission) }

    subject { Policies::Actions.registered_vessel_required?(submission) }

    context "when the task is :new_registration or :unknown" do
      before { submission.task = [:new_registration, :unknown].sample }

      it { expect(subject).to be_falsey }
    end

    context "when the task is :provisional" do
      before { submission.task = :provisional }

      it { expect(subject).to be_falsey }
    end

    context "when the task is :foo (i.e. any other task)" do
      before { submission.task = :foo }

      it { expect(subject).to be_truthy }
    end
  end

  context "#editable?" do
    before do
      allow(submission).to receive(:completed?).and_return(completed)
    end

    let(:completed) { false }
    let(:submission) { build(:submission) }

    subject { submission.editable? }

    it { expect(subject).to be_truthy }

    context "when the current_state is completed" do
      let(:completed) { true }

      it { expect(subject).to be_falsey }
    end

    context "when Policies::Workflow.approved_name_required?" do
      before do
        allow(Policies::Workflow)
          .to receive(:approved_name_required?)
          .and_return(true)
      end

      it { expect(subject).to be_falsey }
    end
  end

  context "#actionable?" do
    let(:submission) do
      build(:submission, source: source, state: current_state, part: part)
    end

    let(:source) { :online }
    let(:current_state) { :assigned }
    let(:part) { :part_3 }

    subject { submission.actionable? }

    context "when the source is :online" do
      before do
        expect(Policies::Definitions)
          .to receive(:submission_errors)
          .with(submission)
          .and_return([])
      end

      it { expect(subject).to be_truthy }
    end

    context "when the part is not :part_3 and there are submission errors" do
      let(:part) { :part_2 }

      it { expect(subject).to be_truthy }

      context "and the current_state is :completed" do
        let(:current_state) { :completed }

        it { expect(subject).to be_falsey }
      end
    end

    context "when the source is :manual_entry" do
      let(:source) { :manual_entry }

      it { expect(subject).to be_truthy }

      context "and the current_state is :completed" do
        let(:current_state) { :completed }

        it { expect(subject).to be_falsey }
      end
    end
  end

  describe "approvable?" do
    let(:submission) { build(:submission) }

    before do
      expect(Policies::Definitions)
        .to receive(:approval_errors)
        .and_return(some_approval_errors)
    end

    subject { submission.approvable? }

    context "with approval_errors" do
      let(:some_approval_errors) { [:unpaid, :frozen] }

      it { expect(subject).to be_falsey }
    end

    context "with no approval_errors" do
      let(:some_approval_errors) { [] }

      it { expect(subject).to be_truthy }
    end
  end
end
