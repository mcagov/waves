require "rails_helper"

describe Submission::Task do
  context "#ref_no" do
    let(:submission_task) { create(:submission_task) }
    subject { submission_task.ref_no }

    it { expect(subject).to eq("#{submission_task.submission.ref_no}/1") }
  end

  context "#start_date" do
    let(:submission) { create(:submission, received_at: "21/07/2016") }
    let(:submission_task) { create(:submission_task, submission: submission) }
    subject { submission_task.start_date }

    it { expect(subject).to eq("21/07/2016".to_date) }
  end

  context "#price" do
    let(:submission_task) do
      create(
        :submission_task,
        submission: create(:submission, part: :part_1),
        service: create(:demo_service),
        service_level: :standard)
    end
    subject { submission_task.price }

    it { expect(subject).to eq(12400) }
  end

  describe "service_level_validations validations" do
    let(:submission_task) do
      build(
        :submission_task,
        service_level: service_level,
        service: create(:standard_only_service))
    end
    before { submission_task.valid? }

    context "is required" do
      let(:service_level) { nil }
      it { expect(submission_task.errors).to include(:service_level) }
    end

    context "is an allowed type" do
      let(:service_level) { :standard }
      it { expect(submission_task.errors).not_to include(:service_level) }
    end

    context "is a disallowed type" do
      let(:service_level) { :premium }
      it { expect(submission_task.errors).to include(:service_level) }
    end
  end

  context "#target_date" do
    let(:submission_task) { create(:submission_task) }
    subject { submission_task.target_date }

    it "is initialised as blank" do
      expect(subject).to be_blank
    end

    context "#confirm" do
      before do
        expect(TargetDate)
          .to receive(:for_task).with(submission_task).and_return("13/11/2012")

        submission_task.confirm!
      end

      it { expect(submission_task.target_date).to eq("13/11/2012".to_date) }
    end
  end

  describe "state machine events" do
    let(:submission_task) { create(:submission_task) }
    let(:user) { create(:user) }

    context "#confirm!" do
      before do
        expect(submission_task).to receive(:set_defaults)
      end

      it { submission_task.confirm! }
    end

    context "#claim!" do
      before do
        submission_task.confirm!
        submission_task.claim!(user)
      end

      it { expect(submission_task.claimant).to eq(user) }
    end

    context "#refer!" do
      before do
        submission_task.confirm!
        submission_task.claim!(user)
        submission_task.refer!
      end

      it { expect(submission_task.claimant).to be_nil }
    end

    context "#unclaim!" do
      before do
        submission_task.confirm!
        submission_task.claim!(user)
        submission_task.unclaim!
      end

      it { expect(submission_task.claimant).to be_nil }
    end

    context "#complete!" do
      before do
        submission_task.confirm!
        submission_task.claim!(user)
        submission_task.complete!
      end

      it { expect(submission_task).to be_completed }
    end

    context "#cancel!" do
      before do
        submission_task.confirm!
        submission_task.claim!(user)
        submission_task.cancel!
      end

      it { expect(submission_task).to be_cancelled }
    end

    context "#unrefer!" do
      before do
        submission_task.confirm!
        submission_task.claim!(user)
        submission_task.refer!
        submission_task.unrefer!
      end

      it { expect(submission_task).to be_unclaimed }
    end
  end
end
