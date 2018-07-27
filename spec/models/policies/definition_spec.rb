require "rails_helper"

describe Policies::Definitions do
  describe ".approval_errors" do
    subject { described_class.approval_errors(submission) }

    context "in general (i.e. not frozen)" do
      let!(:submission) { create(:assigned_submission) }

      it { expect(subject).to be_empty }
    end

    context "for a task that does not write to the registry" do
      let(:submission) do
        create(:submission, application_type: :issue_csr,
                            registered_vessel: create(:registered_vessel))
      end

      it { expect(subject).to be_empty }
    end

    context "manual_override" do
      let(:submission) do
        build(:submission, application_type: :manual_override, changeset: [])
      end

      context "when the vessel name is blank" do
        it { expect(subject).to include(:vessel_required) }
      end

      context "when there are no owners" do
        it { expect(subject).to include(:owners_required) }
      end
    end

    context "frozen /unfrozen" do
      let(:submission) { create(:assigned_submission) }

      before do
        allow(submission)
          .to receive(:registration_status).and_return(:frozen)
      end

      it { expect(subject).to include(:vessel_frozen) }
    end

    context "with outstanding declarations" do
      let!(:submission) { create(:incomplete_submission) }

      it { expect(subject).to include(:declarations_required) }
    end

    context "awaiting_payment" do
      let!(:submission) { create(:submission_task, price: 100).submission }

      it { expect(subject).to include(:payment_required) }
    end

    context "correspondent must be set" do
      let(:error_key) { :correspondent_required }
      let(:submission) { create(:incomplete_submission, part: part) }

      context "with a part_3 submission" do
        let(:part) { :part_3 }

        it { expect(subject).not_to include(error_key) }
      end

      context "with a submission for another part" do
        let(:part) { :part_2 }

        it { expect(subject).to include(error_key) }

        context "when a correspondent is assigned" do
          before do
            submission.correspondent_id = submission.owners.first.id
            submission.save!
          end

          it { expect(subject).not_to include(error_key) }
        end
      end
    end

    context "shareholding count must total 64" do
      let(:error_key) { :shareholding_count }
      let(:submission) { create(:incomplete_submission, part: part) }

      context "for a vessel that doesn't use shareholding" do
        let(:part) { :part_2 }

        before do
          dbl_shareholding = double("ShareHolding", status: shareholding_status)

          allow(ShareHolding)
            .to receive(:new).and_return(dbl_shareholding)
        end

        context "when the shareholding status is :complete" do
          let(:shareholding_status) { :complete }

          it { expect(subject).not_to include(error_key) }
        end

        context "when the shareholding status is not :complete" do
          let(:shareholding_status) { :foo }

          it { expect(subject).to include(error_key) }
        end
      end

      context "for a vessel that doesn't use shareholding" do
        let(:part) { :part_4 }

        it { expect(subject).not_to include(error_key) }
      end
    end

    context "carving_marking_receipt" do
      let(:error_key) { :carving_marking_receipt }

      context "in general" do
        let!(:submission) { create(:incomplete_submission) }

        it { expect(subject).not_to include(error_key) }
      end

      context "when a Carving & Marking Note has been issued" do
        let!(:carving_and_marking) { create(:carving_and_marking) }
        let!(:submission) { carving_and_marking.submission }

        it { expect(subject).to include(error_key) }

        context "when the Carving & Marking note has been received" do
          before do
            submission.update_attribute(
              :carving_and_marking_received_at, Time.zone.now)
          end

          it { expect(subject).not_to include(error_key) }
        end
      end
    end
  end

  context ".registration_type" do
    subject { described_class.registration_type(obj) }

    context "for a submission" do
      let(:obj) do
        build(:submission,
              changeset: { vessel_info: { registration_type: :simple } })
      end

      it { expect(subject).to eq(:simple) }
    end

    context "for a registered_vessel" do
      let(:obj) do
        build(:registered_vessel, registration_type: :full)
      end

      it { expect(subject).to eq(:full) }
    end

    context "for a decorated registered_vessel" do
      let(:obj) do
        Decorators::Vessel.new(
          build(:registered_vessel, registration_type: :full))
      end

      it { expect(subject).to eq(:full) }
    end

    context "for a declaration" do
      let(:obj) do
        create(
          :declaration,
          submission: build(
            :submission,
            changeset: { vessel_info: { registration_type: :fishing } }))
      end

      it { expect(subject).to eq(:fishing) }
    end
  end

  context ".charterable?" do
    subject { described_class.charterable?(vessel) }

    context "by default" do
      let(:vessel) { build(:registered_vessel, part: :part_2) }

      it { expect(subject).to be_falsey }
    end

    context "for a :part_4 vessel" do
      let(:vessel) { build(:registered_vessel, part: :part_4) }

      it { expect(subject).to be_truthy }
    end
  end

  context ".mortgageable?" do
    subject { described_class.mortgageable?(vessel) }

    context "by default" do
      let(:vessel) do
        build(:registered_vessel, part: :part_2, registration_type: :simple)
      end

      it { expect(subject).to be_falsey }
    end

    context "for a :part_1 vessel" do
      let(:vessel) { build(:registered_vessel, part: :part_1) }

      it { expect(subject).to be_truthy }
    end

    context "for a :part_2, :full vessel" do
      let(:vessel) do
        build(:registered_vessel, part: :part_2, registration_type: "full")
      end

      it { expect(subject).to be_truthy }
    end
  end

  context ".manageable?" do
    subject { described_class.manageable?(vessel) }

    context "by default" do
      let(:vessel) do
        build(:registered_vessel, part: :part_1)
      end

      it { expect(subject).to be_truthy }
    end

    context "for a :part_2 vessel" do
      let(:vessel) { build(:registered_vessel, part: :part_2) }

      it { expect(subject).to be_falsey }
    end
  end

  context ".part_4_non_fishing?" do
    subject { described_class.part_4_non_fishing?(vessel) }

    context "for a :part_4 fishing vessel" do
      let(:vessel) do
        build(:part_4_fishing_vessel)
      end

      it { expect(subject).to be_falsey }
    end

    context "for a :part_4 non-fishing vessel" do
      let(:vessel) { build(:registered_vessel, part: :part_4) }

      it { expect(subject).to be_truthy }
    end
  end
end
