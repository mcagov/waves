require "rails_helper"

describe Policies::Definitions do
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
          submission: create(
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
