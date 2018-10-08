require "rails_helper"

describe Decorators::Submission, type: :model do
  context "#delivery_description" do
    let!(:submission) { build(:submission) }

    subject { described_class.new(submission).delivery_description }

    it { expect(subject).to match(/BOB DOLE, 11 DOWNING ST/) }
  end

  context "#changed_vessel_attribute" do
    subject do
      described_class.new(submission).changed_vessel_attribute(:name)
    end

    context "for a new registration" do
      let(:submission) do
        build(:submission, application_type: :new_registration)
      end

      it { expect(subject).to be_nil }
    end

    context "when there is a registered_vessel" do
      context "when the name has not been changed" do
        let(:registered_vessel) { create(:registered_vessel) }

        let(:submission) do
          create(
            :submission,
            registered_vessel: registered_vessel,
            changeset: { vessel_info: { name: registered_vessel.name } })
        end

        it { expect(subject).to be_nil }
      end

      context "when the name has been changed" do
        let(:submission) do
          create(
            :submission,
            :part_3_vessel,
            changeset: { vessel_info: { name: "NEW NAME" } })
        end

        it { expect(subject).to eq(submission.registered_vessel.name) }
      end
    end
  end

  context "#can_issue_carving_and_marking?" do
    let(:decorated_submission) { described_class.new(create(:submission)) }
    subject { decorated_submission.can_issue_carving_and_marking? }

    context "when it can" do
      before do
        expect(decorated_submission)
          .to receive(:vessel_reg_no).and_return(true)
      end

      it { expect(subject).to be_truthy }
    end

    context "when it has no vessel_reg_no" do
      before do
        expect(decorated_submission)
          .to receive(:vessel_reg_no).and_return(false)
      end

      it { expect(subject).to be_falsey }
    end
  end
end
