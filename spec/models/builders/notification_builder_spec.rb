require "rails_helper"

describe Builders::NotificationBuilder do
  context ".application_approval" do
    let(:submission) { create(:completed_submission) }

    before do
      allow_any_instance_of(DeprecableTask)
        .to receive(:emails_application_approval?)
        .and_return(sends_email?)

      described_class.application_approval(submission, create(:user))
    end

    context "when an email is sent" do
      let(:sends_email?) { true }

      it { expect(Notification::ApplicationApproval.count).to eq(1) }
    end

    context "when an email is not sent" do
      let(:sends_email?) { false }

      it { expect(Notification::ApplicationApproval.count).to eq(0) }
    end
  end
end
