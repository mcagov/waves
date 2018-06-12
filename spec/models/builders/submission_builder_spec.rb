require "rails_helper"

describe Builders::SubmissionBuilder do
  describe "#build_defaults" do
    let!(:submission) do
      Submission.new(
        part: :part_3,
        changeset: changeset,
        registry_info: registry_info,
        registered_vessel: registered_vessel,
        declarations: declarations,
        applicant_name: "BOB",
        applicant_email: "bob@example.com",
        applicant_is_agent: applicant_is_agent)
    end

    let!(:changeset) { nil }
    let!(:registry_info) { nil }
    let!(:registered_vessel) { nil }
    let!(:declarations) { [] }
    let!(:applicant_is_agent) { false }

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

      it "builds the service_level as :standard" do
        expect(submission.service_level.to_sym).to eq(:standard)
      end

      context "with :premium service_level" do
        let(:changeset) { { service_level: { level: :premium } } }

        it "builds the service_level as :premium" do
          expect(submission.service_level.to_sym).to eq(:premium)
        end
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

    context "when the applicant is an agent" do
      let!(:applicant_is_agent) { true }

      it "builds the agent in the changeset" do
        expect(submission.agent.name).to eq("BOB")
        expect(submission.agent.email).to eq("bob@example.com")
      end

      context "when there is already an agent" do
        let!(:changeset) { agent_sample_data }
        let(:agent) { submission.agent }

        it "builds the agent name and email from the applicant" do
          expect(agent.name).to eq("BOB")
          expect(agent.email).to eq("bob@example.com")
        end

        it "retains the agent details that were in the registry_info" do
          expect(agent.phone_number).to eq("12345")
          expect(agent.address_1).to eq("1 MAIN STREET")
        end
      end
    end

    context "when the changeset is populated" do
      let!(:changeset) { submission_changeset_sample_data }

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
          expect(submission.vessel.name)
            .to eq(submission.symbolized_registry_info[:vessel_info][:name])
        end
      end

      context "when there are no declarations" do
        let!(:changeset) { submission_changeset_sample_data }

        it "builds the declarations from the changeset" do
          expect(submission.reload.declarations[0].owner.name).to eq("ALICE")
          expect(submission.declarations[1].owner.name).to eq("BOB")
        end

        it "builds the declaration_groups" do
          expect(submission.reload.declaration_groups.length).to eq(1)
        end

        context "running #build_defaults again" do
          it "does not alter the declarations or declaration_groups" do
            described_class.build_defaults(submission)
            expect(submission.reload.declarations.length).to eq(2)
            expect(submission.reload.declaration_groups.length).to eq(1)
          end
        end
      end

      context "with managing_owner and correspondent" do
        it "assigns the managing_owner_id and correspondent_id" do
          expect(submission.managing_owner.name).to eq("ALICE")
          expect(submission.correspondent.name).to eq("Carol")
        end
      end

      context "with engines" do
        let(:submission_engine) { submission.reload.engines.first }

        it "builds the engines from the changeset" do
          expect(submission_engine.make).to eq("DUCATI")
        end

        context "running #build_defaults again" do
          it "does not alter the engines" do
            described_class.build_defaults(submission)
            expect(submission.reload.engines.first).to eq(submission_engine)
          end
        end
      end

      context "with managers" do
        let(:submission_manager) { submission.reload.managers.first }

        it "builds the managers from the changeset" do
          expect(submission_manager.safety_management.address_1).to eq("SM1")
        end

        context "running #build_defaults again" do
          it "does not alter the managers" do
            described_class.build_defaults(submission)
            expect(submission.reload.managers.first).to eq(submission_manager)
          end
        end
      end

      context "with mortgages" do
        let(:submission_mortgage) { submission.reload.mortgages.first }

        it "builds the mortgages from the changeset" do
          expect(submission_mortgage.mortgagees.first.name).to eq("Mary")
        end

        context "running #build_defaults again" do
          it "does not alter the mortgages" do
            described_class.build_defaults(submission)
            expect(submission.reload.mortgages.first).to eq(submission_mortgage)
          end
        end
      end

      context "with charterers" do
        let(:submission_charterer) { submission.reload.charterers.first }

        it "builds the charterers from the changeset" do
          expect(submission_charterer.charter_parties.first.name).to eq("Carol")
        end

        context "running #build_defaults again" do
          it "does not alter the charterers" do
            described_class.build_defaults(submission)
            expect(submission.reload.charterers.first)
              .to eq(submission_charterer)
          end
        end
      end

      context "with beneficial_owners" do
        let(:beneficial_owner) { submission.reload.beneficial_owners.first }

        it "builds the beneficial_owners from the changeset" do
          expect(beneficial_owner.name).to eq("Barry")
        end

        context "running #build_defaults again" do
          it "does not alter the beneficial_owners" do
            described_class.build_defaults(submission)
            expect(submission.reload.beneficial_owners.first)
              .to eq(beneficial_owner)
          end
        end
      end

      context "with directed_bys" do
        let(:directed_by) { submission.reload.directed_bys.first }

        it "builds the directed_bys from the changeset" do
          expect(directed_by.name).to eq("Dennis")
        end

        context "running #build_defaults again" do
          it "does not alter the directed_bys" do
            described_class.build_defaults(submission)
            expect(submission.reload.directed_bys.first)
              .to eq(directed_by)
          end
        end
      end

      context "with managed_bys" do
        let(:managed_by) { submission.reload.managed_bys.first }

        it "builds the managed_bys from the changeset" do
          expect(managed_by.name).to eq("Marvin")
        end

        context "running #build_defaults again" do
          it "does not alter the managed_bys" do
            described_class.build_defaults(submission)
            expect(submission.reload.managed_bys.first)
              .to eq(managed_by)
          end
        end
      end
    end
  end
end

def agent_sample_data
  {
    agent: {
      name: "ROBERT",
      email: "robert@example.com",
      phone_number: "12345",
      address_1: "1 MAIN STREET",
    },
  }
end

def submission_changeset_sample_data
  {
    owners: owner_sample_data,
    vessel_info: vessel_sample_data,
    shareholder_groups: shareholder_groups_sample_data,
  }
end

def vessel_sample_data # rubocop:disable Metrics/MethodLength
  {
    part: :part_3,
    name: "MY BOAT", number_of_hulls: 1,
    owners: owner_sample_data.map { |owner| Register::Owner.new(owner) },
    engines: [create(:engine, make: "DUCATI")],
    beneficial_owners: [create(:beneficial_owner, name: "Barry")],
    directed_bys: [create(:directed_by, name: "Dennis")],
    managed_bys: [create(:managed_by, name: "Marvin")],
    managers: [create(:manager,
                      safety_management: create(:safety_management,
                                                address_1: "SM1"))],
    mortgages: [create(:mortgage,
                       mortgagees: [create(:mortgagee, name: "Mary")])],

    charterers: [create(:charterer,
                        charter_parties: [
                          create(:charter_party, name: "Carol",
                                                 correspondent: true)])]
  }
end

def owner_sample_data
  [
    { name: "ALICE", email: "alice@example.com", managing_owner: true },
    { name: "BOB", email: nil },
  ]
end

def shareholder_groups_sample_data
  [
    {
      shares_held: 10,
      group_member_keys: ["ALICE;alice@example.com", "BOB;"],
    },
  ]
end
