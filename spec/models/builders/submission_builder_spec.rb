require "rails_helper"

describe Builders::SubmissionBuilder do
  describe "#build_defaults" do
    let!(:submission) do
      Submission.new(
        changeset: changeset,
        registry_info: registry_info,
        registered_vessel: registered_vessel,
        declarations: declarations)
    end

    let!(:changeset) { nil }
    let!(:registry_info) { nil }
    let!(:registered_vessel) { nil }
    let!(:declarations) { [] }

    before { described_class.build_defaults(submission) }

    context "in general" do
      it "defaults to task = new_registration" do
        expect(submission.task.to_sym).to eq(:new_registration)
      end

      it "defaults to source = online" do
        expect(submission.source.to_sym).to eq(:online)
      end

      it "defaults to part = part_3" do
        expect(submission.part.to_sym).to eq(:part_3)
      end

      it "builds the ref_no" do
        expect(submission.ref_no).to be_present
      end

      it "does not build the registry info" do
        expect(submission.registry_info).to be_nil
      end

      it "does not alter the changeset" do
        expect(submission.changeset).to eq(changeset)
      end

      it "does not build any declarations" do
        expect(submission.declarations).to be_empty
      end
    end

    context "when the changeset is populated" do
      let!(:changeset) { vessel_owner_sample_data }

      it "builds a declaration for each of the two owners" do
        expect(submission.declarations.count).to eq(2)
      end

      it "does not alter the changeset" do
        expect(submission.symbolized_changeset[:vessel_info][:name])
          .to eq("MY BOAT")
        expect(submission.symbolized_changeset[:owners][0][:name])
          .to eq("ALICE")
      end
    end

    context "with a registered vessel" do
      let!(:registered_vessel) do
        Register::Vessel.create(vessel_sample_data)
      end

      context "when the registry_info has not been set" do
        it "builds the registry_info#vessel_info" do
          expect(submission.symbolized_registry_info[:vessel_info][:name])
            .to eq("MY BOAT")
        end

        it "builds the registry_info#owners" do
          expect(submission.symbolized_registry_info[:owners][0][:name])
            .to eq("ALICE")
        end
      end

      context "when the registry_info is already populated" do
        let!(:registry_info) { { foo: "bar" } }

        it "does not alter the registry_info" do
          expect(submission.symbolized_registry_info).to eq(foo: "bar")
        end
      end

      context "when the changeset is blank" do
        it "builds the changeset from the registry_info" do
          expect(submission.symbolized_changeset)
            .to eq(submission.symbolized_registry_info)
        end
      end

      context "when the changeset is already populated" do
        let!(:changeset) { { foo: "bar" } }

        it "does not alter the changeset" do
          expect(submission.symbolized_changeset[:foo]).to eq("bar")
        end
      end

      context "when there are no declarations" do
        it "builds the declarations from the changeset" do
          expect(submission.reload.declarations[0].owner.name).to eq("ALICE")
          expect(submission.declarations[1].owner.name).to eq("BOB")
        end

        context "running #build_defaults again" do
          it "does not alter the declarations" do
            described_class.build_defaults(submission)
            expect(submission.reload.declarations.length).to eq(2)
          end
        end
      end
    end
  end
end

def vessel_owner_sample_data
  {
    owners: owner_sample_data,
    vessel_info: vessel_sample_data,
  }
end

def vessel_sample_data
  {
    name: "MY BOAT", number_of_hulls: 1,
    owners: owner_sample_data.map { |owner| Register::Owner.new(owner) }
  }
end

def owner_sample_data
  [
    { name: "ALICE", email: "alice@example.com" },
    { name: "BOB", email: "bob@example.com" },
  ]
end