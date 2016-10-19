require "rails_helper"

describe Policies::Submission do
  describe "#officer_intervention_required?" do
    let!(:submission) { create(:submission, changeset: nil) }

    subject { submission.officer_intervention_required? }

    context "when there is no changeset" do
      it { expect(subject).to be_truthy }

      context "when the officer has added something to the changeset" do
        before do
          submission.update_attributes(changeset: { foo: :bar })
        end

        it { expect(subject).to be_falsey }
      end
    end
  end

  context "#editable?" do
    before do
      allow(submission).to receive(:completed?).and_return(completed)
      allow(submission).to receive(:printing?).and_return(printing)
    end

    let(:completed) { false }
    let(:printing) { false }
    let(:submission) { build(:submission) }

    subject { submission.editable? }

    it { expect(subject).to be_truthy }

    context "when the current_state is printing" do
      let(:printing) { true }

      it { expect(subject).to be_falsey }
    end

    context "when the current_state is completed" do
      let(:completed) { true }

      it { expect(subject).to be_falsey }
    end
  end

  context "#actionable?" do
    before do
      expect(Policies::Submission)
        .to receive(:approvable?)
    end

    it { build(:submission).approvable? }
  end

  context "#printing_completed?" do
    subject { submission.printing_completed? }

    context "with outstanding print jobs" do
      let!(:submission) { create_printing_submission! }

      it { expect(subject).to be_falsey }
    end

    context "with no outstanding print jobs" do
      let!(:submission) { create_completed_submission! }

      it { expect(subject).to be_truthy }
    end
  end

  describe "approvable?" do
    let!(:submission) { create_incomplete_submission! }
    subject { submission.approvable? }

    context "with outstanding declarations" do
      it { expect(subject).to be_falsey }

      context "with completed declarations and no payment" do
        before { submission.declarations.incomplete.map(&:declared!) }

        it { expect(subject).to be_falsey }

        context "with completed declarations and payment" do
          before do
            allow(AccountLedger)
              .to receive(:paid?).with(submission).and_return(true)
          end

          it { expect(subject).to be_truthy }
        end
      end
    end
  end
end
