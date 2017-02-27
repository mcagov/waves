require "rails_helper"

describe Registration do
  context "#delivery_address" do
    let(:registration) do
      create(:registration, submission_ref_no: submission_ref_no)
    end

    subject { registration.delivery_address }

    context "with a submission" do
      let(:submission) { create(:submission) }
      let(:submission_ref_no) { submission.ref_no }

      context "that has an alternate delivery_address" do
        it "uses the submission's delivery address" do
          expect(subject.name).to eq(submission.delivery_address.name)
        end
      end

      context "that does not have an alternate delivery_address" do
        let(:submission) { create(:submission, changeset: {}) }
        let(:submission_ref_no) { submission.ref_no }

        it "uses the first owner's delivery address" do
          expect(subject.name).to eq(registration.owners.first.name)
        end
      end
    end

    context "without a submission" do
      let(:submission_ref_no) { nil }

      it "uses the first owner's delivery address" do
        expect(subject.name).to eq(registration.owners.first.name)
      end
    end
  end

  context "#part" do
    let(:registration) { create(:registration, registry_info: registry_info) }

    context "when the registry_info is not defined (edge case)" do
      let(:registry_info) { nil }

      it "defaults to part_3" do
        expect(registration.part.to_sym).to eq(:part_3)
      end
    end

    context "when the registry_info#vessel_info is part_1" do
      let(:registry_info) { { vessel_info: { part: "part_1" } } }

      it { expect(registration.part).to eq(:part_1) }
    end
  end
end
