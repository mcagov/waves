require "rails_helper"

describe Search, type: :model do
  context ".submissions" do
    context "search by vessel name" do
      let!(:submission) { create(:submission) }
      let!(:part) { nil }

      subject { Search.submissions("Boaty McBoatface", part) }

      it { expect(subject.first).to eq(submission) }

      context "in part_1" do
        let(:part) { :part_1 }

        it { expect(subject).to be_empty }
      end

      context "in part_3" do
        let(:part) { :part_3 }

        it { expect(subject.length).to eq(1) }
      end
    end

    context "search by ref no" do
      let!(:submission) { create(:submission) }
      let!(:part) { nil }

      subject { Search.submissions(submission.ref_no, part) }

      it { expect(subject.first).to eq(submission) }

      context "in part_1" do
        let(:part) { :part_1 }

        it { expect(subject).to be_empty }
      end

      context "in part_3" do
        let(:part) { :part_3 }

        it { expect(subject.length).to eq(1) }
      end
    end

    xcontext "search by finance_payment inputs" do
      let!(:finance_payment) do
        create(:locked_finance_payment, vessel_name: "CARIBE",
                                        application_ref_no: "ABC123",
                                        applicant_name: "HARRY")
      end

      subject { Search.submissions(term) }

      context "vessel_name" do
        let(:term) { "CARIBE" }

        it { expect(subject.length).to eq(1) }
      end

      context "application_ref_no" do
        let(:term) { "ABC123" }

        it { expect(subject.length).to eq(1) }
      end

      context "application_name" do
        let(:term) { "HARRY" }

        it { expect(subject.length).to eq(1) }
      end

      context "something that does not exist" do
        let(:term) { "FOOBAR" }

        it { expect(subject).to be_empty }
      end
    end
  end

  context ".vessels" do
    context "search by vessel name" do
      let!(:vessel) { create(:registered_vessel, name: "BOBS BOAT") }
      let!(:part) { nil }

      subject { Search.vessels("BOB", part) }

      it { expect(subject.first).to eq(vessel) }

      context "in part_1" do
        let(:part) { :part_1 }

        it { expect(subject).to be_empty }
      end

      context "in part_3" do
        let(:part) { :part_3 }

        it { expect(subject.first).to eq(vessel) }
      end
    end
  end

  context ".similar_vessels" do
    let!(:same_name) do
      create(:registered_vessel, name: "CELEBRATOR DOPPELBOCK")
    end

    let!(:same_mmsi) { create(:registered_vessel, mmsi_number: "233878594") }
    let!(:blank_mmsi) { create(:registered_vessel, mmsi_number: "") }
    let!(:different_mmsi) { create(:registered_vessel, mmsi_number: rand(9)) }
    let!(:same_hin) { create(:registered_vessel, hin: "foo") }
    let!(:blank_hin) { create(:registered_vessel, hin: nil) }
    let!(:same_radio) { create(:registered_vessel, radio_call_sign: "4RWO0K") }
    let!(:blank_radio) { create(:registered_vessel, radio_call_sign: nil) }

    let!(:vessel) { create_submission_from_api!.vessel }
    subject { Search.similar_vessels(:part_3, vessel) }

    it "contains the same_name" do
      expect(subject).to include(same_name)
    end

    it "contains the same_mmsi" do
      expect(subject).to include(same_mmsi)
    end

    it "does not contain the different_mmsi" do
      expect(subject).not_to include(different_mmsi)
    end

    it "does not contain the blank_mmsi" do
      expect(subject).not_to include(blank_mmsi)
    end

    it "contains the same_hin" do
      expect(subject).to include(same_mmsi)
    end

    it "contains the blank_hin" do
      expect(subject).not_to include(blank_hin)
    end

    it "contains the same_radio_call_sign" do
      expect(subject).to include(same_radio)
    end

    it "does not contain the different_mmsi" do
      expect(subject).not_to include(different_mmsi)
    end
  end
end
