require "rails_helper"

describe Activity do
  describe "#registration_officer?" do
    subject { described_class.new(part).registration_officer? }

    context "with a reg officer" do
      let(:part) { :part_3 }

      it { expect(subject).to be_truthy }
    end

    context "with a finance person" do
      let(:part) { :finance }

      it { expect(subject).to be_falsey }
    end

    context "with a reports person" do
      let(:part) { :reports }

      it { expect(subject).to be_falsey }
    end
  end

  context "#task_types" do
    subject { described_class.new(part).task_types }

    context "part_1" do
      let(:part) { :part_1 }

      it { expect(uses_task?(subject, :issue_csr)).to be_truthy }
      it { expect(uses_task?(subject, :provisional)).to be_truthy }
      it { expect(uses_task?(subject, :mortgage)).to be_truthy }
      it { expect(uses_task?(subject, :re_registration)).to be_truthy }
    end

    context "part_2" do
      let(:part) { :part_2 }

      it { expect(uses_task?(subject, :issue_csr)).to be_falsey }
      it { expect(uses_task?(subject, :provisional)).to be_truthy }
      it { expect(uses_task?(subject, :mortgage)).to be_truthy }
      it { expect(uses_task?(subject, :re_registration)).to be_truthy }
    end

    context "part_3" do
      let(:part) { :part_3 }

      it { expect(uses_task?(subject, :issue_csr)).to be_falsey }
      it { expect(uses_task?(subject, :provisional)).to be_falsey }
      it { expect(uses_task?(subject, :mortgage)).to be_falsey }
      it { expect(uses_task?(subject, :re_registration)).to be_truthy }
    end

    context "part_4" do
      let(:part) { :part_4 }

      it { expect(uses_task?(subject, :issue_csr)).to be_truthy }
      it { expect(uses_task?(subject, :provisional)).to be_falsey }
      it { expect(uses_task?(subject, :mortgage)).to be_falsey }
      it { expect(uses_task?(subject, :re_registration)).to be_falsey }
    end

    context "when the 'part' is of another type" do
      let(:part) { :finance }

      it { expect(uses_task?(subject, :re_registration)).to be_truthy }
    end
  end
end

def uses_task?(task_types, key)
  task_types.map { |el| el[1] }.include?(key)
end
