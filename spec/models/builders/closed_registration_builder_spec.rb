require "rails_helper"

describe Builders::ClosedRegistrationBuilder do
  context ".create" do
    before do
      described_class.create(
        submission,
        "10/10/2012 12:23 PM".to_datetime,
        "Mi Razon",
        "additional details")
    end

    let!(:registered_vessel) { create(:registered_vessel) }

    let!(:submission) do
      create(:submission,
             registered_vessel: registered_vessel, application_type: :closure)
    end

    let(:registration) { registered_vessel.reload.current_registration }

    it "records the closed_at date" do
      expect(registration.closed_at).to eq("10/10/2012 12:23 PM".to_datetime)
    end

    it "records the closure reason" do
      expect(registration.description).to eq("Mi Razon")
    end

    it "records the supporting_info" do
      expect(registration.supporting_info).to eq("additional details")
    end

    it "records the registration#actioned_by" do
      expect(registration.actioned_by).to eq(submission.claimant)
    end
  end
end
