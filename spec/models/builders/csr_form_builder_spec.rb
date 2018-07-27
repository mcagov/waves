require "rails_helper"

describe Builders::CsrFormBuilder do
  context "#build" do
    let!(:vessel) do
      create(
        :registered_vessel,
        part: 1,
        reg_no: "ABC1234",
        name: "PIRATE SHIP",
        port_code: "SU",
        owners: [owner_1, owner_2],
        managers: [manager],
        charterers: [charterer],
        classification_society: "XX",
        classification_society_other: "YY",
        smc_issuing_authority: "SMC_I",
        smc_auditor: "SMC_A",
        issc_issuing_authority: "ISSC_I",
        issc_auditor: "ISSC_A")
    end

    let!(:vessel_with_closed_registration) do
      vessel.current_registration.update_attributes(
        registered_at: "1/1/2010",
        closed_at: "2/2/2010")
      vessel
    end

    let!(:submission) do
      create(
        :assigned_submission,
        application_type: :issue_csr,
        part: :part_1,
        registered_vessel: vessel_with_closed_registration)
    end

    let!(:owner_1) do
      build(
        :registered_owner,
        name: "ALICE", address_1: "AA ST", imo_number: "AA1")
    end

    let!(:owner_2) do
      build(
        :registered_owner,
        name: "BOB", address_1: "BB ST", imo_number: "BB2")
    end

    let!(:manager) do
      build(
        :manager,
        name: "MIKE", address_1: "MIKES HOUSE", imo_number: "12345",
        safety_management: build(:safety_management, address_1: "SM STREET"))
    end

    let!(:charterer) do
      build(
        :charterer,
        charter_parties:
          [build(:charter_party, name: "CHARLIE", address_1: "MAIN STREET")])
    end

    subject { described_class.build(submission) }

    it "assigns the expected attributes" do
      csr_form = subject
      expect(csr_form).to be_persisted
      expect(csr_form.issued_at).to be_present

      expect(csr_form).to have_attributes(
        vessel_id: vessel.id,
        registered_at: Date.new(2010, 1, 1),
        vessel_name: "PIRATE SHIP",
        owner_names: "ALICE; BOB",
        owner_addresses: "AA ST; BB ST",
        charterer_addresses: "MAIN STREET",
        registration_closed_at: Date.new(2010, 2, 2))
    end

    context "with an existing CsrForm" do
      let!(:submission_csr_form) { create(:csr_form, submission: submission) }

      it "retrieves the existing CsrForm" do
        expect(subject).to eq(submission_csr_form)
      end
    end
  end
end
