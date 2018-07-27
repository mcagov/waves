require "rails_helper"

describe Builders::RegistryBuilder do
  context ".create" do
    let(:submission) { init_basic_submission }
    let(:approval_params) { { registration_starts_at: "21/12/2012" } }

    before { described_class.create(submission, approval_params) }

    let(:registered_vessel) { Register::Vessel.last }

    it "creates the expected vessel name" do
      expect(registered_vessel.name).to eq("BOB BARGE")
    end

    it "sets the registry part" do
      expect(registered_vessel.part.to_sym).to eq(:part_3)
    end

    it "creates registered owners in the expect order" do
      expect(registered_vessel.owners.length).to eq(2)
      expect(registered_vessel.owners.first.name).to eq("ALICE")
      expect(registered_vessel.owners.first.alt_address_1).to eq("ALT 1")
      expect(registered_vessel.owners.last.name).to eq("BOB LTD")
    end

    it "sets the registered owners entity type" do
      expect(registered_vessel.owners.first.entity_type.to_sym)
        .to eq(:individual)
      expect(registered_vessel.owners.last.entity_type.to_sym)
        .to eq(:corporate)
    end

    it "creates the registered agent" do
      expect(registered_vessel.reload.agent.name).to eq("Annabel Agent")
    end

    it "ensures the entry_into_service_at is present" do
      expect(registered_vessel.entry_into_service_at).to eq("21/12/2012")
    end

    context "with a task that changes registry details" do
      let(:change_vessel_submission) do
        create(:assigned_submission,
               application_type: :re_registration,
               registered_vessel: registered_vessel,
               changeset: {
                 vessel_info: build(:submission_vessel, name: "DON DINGHY"),
                 owners: [
                   { name: "ALICE" }, { name: "DAVE" }, { name: "ELLEN" }],
               })
      end

      before do
        # workaround the submission validation: vessel_must_be_unique
        Submission.delete_all
        described_class.create(change_vessel_submission, {})
        registered_vessel.reload
      end

      it "updates the vessel name" do
        expect(registered_vessel.name).to eq("DON DINGHY")
      end

      it "creates registered owners in the expect order" do
        expect(registered_vessel.owners.length).to eq(3)
        expect(registered_vessel.owners[0].name).to eq("ALICE")
        expect(registered_vessel.owners[1].name).to eq("DAVE")
        expect(registered_vessel.owners[2].name).to eq("ELLEN")
      end
    end

    context "with an extended submission type (ie. not part_3)" do
      let(:submission) { init_extended_submission }
      let(:alice) { registered_vessel.owners.first }
      let(:bob) { registered_vessel.owners.last }

      it "sets alice as the managing_owner" do
        expect(alice).to be_managing_owner
        expect(bob).not_to be_managing_owner
      end

      it "sets the charter_party Carol as the correspondent" do
        expect(alice).not_to be_correspondent
        expect(bob).not_to be_correspondent
        expect(registered_vessel.charter_parties.last).to be_correspondent
      end

      it "notes that alice has 20 shares" do
        expect(alice.shares_held).to eq(20)
      end

      it "notes that bob is a member of a group holding 10 shares jointly" do
        shareholder_group = registered_vessel.shareholder_groups.first

        expect(shareholder_group.shares_held).to eq(10)
        expect(shareholder_group.shareholder_group_members.map(&:owner))
          .to include(bob)
      end

      it "creates the engines (and keeps the submission's engine" do
        expect(registered_vessel.reload.engines.map(&:make))
          .to include("Honda")
        expect(registered_vessel.reload.engines.map(&:make))
          .to include("Yamaha")

        expect(submission.reload.engines.length).to eq(2)
      end

      it "creates the documents" do
        document = registered_vessel.reload.documents.first
        expect(document.entity_type.to_sym).to eq(:other)
        expect(document.asset.file_file_name).to eq("mca_test.pdf")
      end

      it "creates the managers" do
        manager = registered_vessel.reload.managers.first
        expect(manager.name).to eq("MARY")
        expect(manager.safety_management.address_1).to eq("SM ADDRESS")
      end

      it "creates (and registers) the mortgages" do
        mortgage = registered_vessel.reload.mortgages.first
        expect(mortgage.registered_at).to eq("21/12/2012".to_date)
        expect(mortgage.priority_code).to eq("A")
        expect(mortgage.mortgagors.first.name).to eq("Phil")
        expect(mortgage.mortgagees.first.name).to eq("Mary")
      end

      it "retains the submission's mortgages" do
        expect(submission.reload.mortgages.first.priority_code).to eq("A")
      end

      it "creates the charterers" do
        charterer = registered_vessel.reload.charterers.first
        expect(charterer.reference_number).to eq("CH 1")
        expect(charterer.charter_parties.first.name).to eq("Carol")
        expect(charterer.charter_parties.first.declaration_signed).to be_falsey
      end

      it "retains the submission's charterers" do
        expect(submission.reload.charterers.first.reference_number)
          .to eq("CH 1")
      end

      it "creates the beneficial_owners" do
        beneficial_owner = registered_vessel.reload.beneficial_owners.first
        expect(beneficial_owner.name).to eq("Barry")
      end

      it "creates the representative" do
        representative = registered_vessel.reload.representative
        expect(representative.name).to eq("Ronnie")
      end

      it "creates the directed_by" do
        directed_by = registered_vessel.reload.directed_bys.first
        expect(directed_by.name).to eq("Dennis")
      end

      it "creates the managed_by" do
        managed_by = registered_vessel.reload.managed_bys.first
        expect(managed_by.name).to eq("Marvin")
      end
    end
  end
end

# rubocop:disable all
def init_basic_submission
  submission =
    create(:submission,
           changeset: {
             vessel_info: build(:submission_vessel, name: "BOB BARGE"),
             agent: build(:submission_agent),
             representative: build(:submission_representative, name: "Ronnie"),
           })

  submission.declarations.create(
    owner: Declaration::Owner.new({ name: "ALICE", alt_address_1: "ALT 1" }),
    shares_held: 20)

  submission.declarations.create(
    entity_type: :corporate, owner: Declaration::Owner.new({ name: "BOB LTD" }))

  submission.engines.create(make: "Honda")
  submission.engines.create(make: "Yamaha")

  submission.documents.create(
    entity_type: :other,
    assets: [create(:asset)])

  submission.managers.create(
    name: "MARY",
    safety_management: SafetyManagement.new(address_1: "SM ADDRESS"))

  submission.mortgages.create(
    priority_code: "A",
    mortgage_type: "Principle Sum",
    mortgagors: [Mortgagor.new(name: "Phil")],
    mortgagees: [Mortgagee.new(name: "Mary")])

  submission.charterers.create(
    reference_number: "CH 1",
    charter_parties: [build(:charter_party, name: "Carol")])

  submission.beneficial_owners.create(
    name: "Barry")

  submission.directed_bys.create(
    name: "Dennis")

  submission.managed_bys.create(
    name: "Marvin")

  submission
end

def init_extended_submission
  submission = init_basic_submission
  submission.update_attributes(
    managing_owner_id: submission.declarations.first.owner.id,
    correspondent_id: submission.charter_parties.last.id)

  submission.declaration_groups.create(
    shares_held: 10,
    default_group_member: submission.declarations.last.owner.id)

  submission
end
# rubocop:enable all
