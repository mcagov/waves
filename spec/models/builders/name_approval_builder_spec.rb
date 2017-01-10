require "rails_helper"

describe Builders::NameApprovalBuilder do
  let!(:submission) do
    create(:assigned_submission,
           part: :part_2,
           task: :new_registration)
  end

  let(:name_approval) do
    Submission::NameApproval.new(
      name: "BOBS BOAT",
      part: :part_2,
      port_code: "SU",
      port_no: port_no,
      registration_type: :full,
      net_tonnage: 999)
  end

  before { described_class.create(submission, name_approval) }

  context ".create" do
    context "with valid data" do
      let(:port_no) { 123 }
      let(:registered_vessel) { submission.reload.registered_vessel }

      it "builds the vessel reg_no" do
        expect(registered_vessel.reg_no).to be_present
      end

      it "saves the vessel port_no" do
        expect(registered_vessel.port_no).to eq(123)
      end

      it "saves the vessel name" do
        expect(registered_vessel.name).to eq("BOBS BOAT")
      end

      it "saves the vessel port_code" do
        expect(registered_vessel.port_code).to eq("SU")
      end

      it "saves the vessel net_tonnage" do
        expect(registered_vessel.net_tonnage).to eq(999)
      end

      it "saves the vessel registration_type" do
        expect(registered_vessel.registration_type).to eq("full")
      end

      it "sets the name_approved_until" do
        expect(registered_vessel.name_approved_until).to be_present
      end

      context "but no port_no" do
        let(:port_no) { "" }

        it { expect(registered_vessel.port_no).not_to be_blank }
      end
    end
  end
end
