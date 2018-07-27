require "rails_helper"

describe Decorators::Declaration, type: :model do
  context "#declaration_required?" do
    context "for a new declaration" do
      let!(:declaration) { build(:declaration) }

      before do
        task = double(:task)

        expect(DeprecableTask)
          .to receive(:new).with(declaration.submission.task)
          .and_return(task)

        expect(task)
          .to receive(:declarations_required_on_add_owner?)
      end

      it { described_class.new(declaration).declaration_required? }
    end

    context "for an existing declaration" do
      let(:declaration) { create(:declaration, state: declaration_state) }
      subject { described_class.new(declaration).declaration_required? }

      context "when the declaration state is :not_required" do
        let(:declaration_state) { :not_required }

        it { expect(subject).to be_falsey }
      end

      context "when the declaration state is :incomplete" do
        let(:declaration_state) { :incomplete }

        it { expect(subject).to be_truthy }
      end

      context "when the declaration state is :completed" do
        let(:declaration_state) { :completed }

        it { expect(subject).to be_truthy }
      end
    end
  end
end
