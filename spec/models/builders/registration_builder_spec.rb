require "rails_helper"

describe Builders::RegistrationBuilder do
  context ".create" do
    context "with a task for a registered_vessel" do
      let!(:registered_vessel) { create(:registered_vessel) }
      let(:submission) do
        create(:assigned_submission,
               application_type: task,
               registered_vessel: registered_vessel)
      end

      before do
        described_class.create(
          submission,
          registered_vessel,
          "10/10/2012 12:23 PM".to_datetime,
          ends_at)
      end

      let(:registration) { submission.registration }
      let(:task) { :renewal }
      let(:ends_at) { nil }

      context "with a renewal task" do
        it "records the registration date" do
          expect(registration.registered_at)
            .to eq("10/10/2012 12:23 PM".to_datetime)
        end

        it "creates the five year registration" do
          expect(registration.registered_until)
            .to eq("10/10/2017 12:23 PM".to_datetime)
        end

        it "sets the registration#actioned_by" do
          expect(registration.actioned_by)
            .to eq(submission.claimant)
        end

        it "makes a snapshot of the vessel details" do
          expect(registration.vessel[:id]).to eq(registered_vessel.id)
        end

        it "sets the submission#registration" do
          expect(submission.registration).to eq(registration)
        end

        it { expect(registration).not_to be_provisional }
      end

      context "with a provisional_registration task" do
        let(:task) { :provisional }

        it { expect(registration).to be_provisional }
      end

      context "with an #ends_at param" do
        let(:ends_at) { "11/11/2012" }

        it "creates the registration until the expected end_date" do
          expect(registration.registered_until)
            .to eq("11/11/2012".to_datetime)
        end
      end
    end
  end
end
