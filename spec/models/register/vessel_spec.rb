require "rails_helper"

describe Register::Vessel do
  let!(:vessel) { create(:registered_vessel) }

  context ".create" do
    it "generates a vessel#reg_no" do
      expect(vessel.reg_no).to match(/SSR2[0-9]{5}/)
    end

    it "has a registry part" do
      expect(vessel.part).to be_present
    end
  end

  context "#current_registration" do
    let!(:old_registration) do
      create(:ten_year_old_registration, vessel_id: vessel.id)
    end

    let!(:latest_registration) do
      Registration.order("created_at desc").first
    end

    subject { vessel.current_registration }

    it { expect(subject).to eq(latest_registration) }
  end

  context "#first_registration" do
    let!(:old_registration) do
      create(:ten_year_old_registration, vessel_id: vessel.id)
    end

    let!(:latest_registration) do
      Registration.order("created_at desc").first
    end

    subject { vessel.current_registration }

    it { expect(subject).to eq(latest_registration) }
  end

  context "#correspondent" do
    let(:vessel) { create(:registered_vessel) }
    subject { vessel.correspondent }

    context "is the second owner" do
      before do
        vessel.owners.create(name: "Bob", correspondent: true)
      end

      it { expect(vessel.correspondent.name).to eq("Bob") }
    end

    context "is a charter_party" do
      before do
        vessel.charter_parties.first.update_attribute :correspondent, true
      end

      it { expect(vessel.correspondent).to eq(vessel.charter_parties.first) }
    end

    context "is undefined, defaults to first owner" do
      it { expect(vessel.correspondent).to eq(vessel.owners.first) }
    end
  end

  context "#notification_list" do
    let!(:vessel) { build(:registered_vessel) }

    before do
      expect(Builders::NotificationListBuilder)
        .to receive(:for_registered_vessel)
        .with(vessel)
    end

    it { vessel.notification_list }
  end

  context ".registration_status" do
    let!(:vessel) { create(:unregistered_vessel) }
    subject { vessel.reload.registration_status }

    context "with an active registration" do
      before do
        vessel.update_attributes(
          current_registration:
            create(
              :registration,
              vessel_id: vessel.id, registered_until: 1.day.from_now))
      end

      it { expect(subject).to eq(:registered) }
    end

    context "with an expired registration" do
      before do
        create(
          :registration,
          vessel_id: vessel.id, registered_until: 1.week.ago)
      end

      it { expect(subject).to eq(:expired) }
    end

    context "with a closed registration" do
      before do
        create(
          :registration,
          vessel_id: vessel.id, closed_at: 1.day.ago)
      end

      it { expect(subject).to eq(:closed) }
    end

    context "with a frozen vessel" do
      before do
        vessel.update_attribute(:frozen_at, 1.day.ago)
      end

      it { expect(subject).to eq(:frozen) }
    end

    context "without a registration" do
      it { expect(subject).to eq(:pending) }
    end
  end

  context "#prints_registration_certificate?" do
    before do
      allow(vessel).to receive(:registration_status).and_return(status)
    end

    subject { vessel.prints_registration_certificate? }

    context "with status: registered" do
      let(:status) { :registered }

      it { expect(subject).to be_truthy }
    end

    context "with status: foo (i.e. any other status)" do
      let(:status) { :foo }

      it { expect(subject).to be_falsey }
    end
  end

  context "#prints_transcript?" do
    before do
      allow(vessel).to receive(:registration_status).and_return(status)
    end

    subject { vessel.prints_transcript? }

    context "with status: pending" do
      let(:status) { :pending }

      it { expect(subject).to be_falsey }
    end

    context "with status: foo (i.e. any other status)" do
      let(:status) { :foo }

      it { expect(subject).to be_truthy }
    end
  end

  context "#prints_renewal_reminder?" do
    before do
      allow(vessel).to receive(:registration_status).and_return(status)
    end

    subject { vessel.prints_renewal_reminder? }

    context "with status: pending" do
      let(:status) { :pending }

      it { expect(subject).to be_falsey }
    end

    context "with status: foo (i.e. any other status)" do
      let(:status) { :foo }

      it { expect(subject).to be_truthy }
    end
  end

  context "#registry_info" do
    subject { vessel.registry_info }

    context "in general" do
      it "has the vessel attributes" do
        expect(subject[:vessel_info]["name"]).to eq(vessel.name)
      end

      it "has the owner attributes" do
        expect(subject[:owners][0]["name"]).to eq(vessel.owners.first.name)
      end

      it "has the agent attributes" do
        expect(subject[:agent]["name"]).to eq(vessel.agent.name)
      end

      it "has the engine attributes" do
        expect(subject[:engines][0]["make"]).to eq(vessel.engines.first.make)
      end

      it "has the manager attributes" do
        expect(subject[:managers][0][:safety_management]["address_1"])
          .to eq(vessel.managers.first.safety_management.address_1)
      end

      it "has the mortgage attributes" do
        expect(subject[:mortgages][0][:mortgagees][0]["name"])
          .to eq(vessel.mortgages.first.mortgagees.first.name)
      end

      it "has the charterer attributes" do
        expect(subject[:charterers][0][:charter_parties][0]["name"])
          .to eq(vessel.charterers.first.charter_parties.first.name)
      end

      it "has the beneficial_owners attributes" do
        expect(subject[:beneficial_owners][0]["name"])
          .to eq(vessel.beneficial_owners.first.name)
      end

      it "has the directed_by attributes" do
        expect(subject[:directed_bys][0]["name"])
          .to eq(vessel.directed_bys[0].name)
      end

      it "has the managed_by attributes" do
        expect(subject[:managed_bys][0]["name"])
          .to eq(vessel.managed_bys[0].name)
      end

      it "has the representative attributes" do
        expect(subject[:representative]["name"])
          .to eq(vessel.representative.name)
      end
    end

    context "shareholder_groups" do
      before do
        group = vessel.shareholder_groups.create(shares_held: 10)
        group.shareholder_group_members.create(owner_id: vessel.owners.first.id)
      end

      it "has the shareholder_groups" do
        owner_key = "#{vessel.owners.first.name};#{vessel.owners.first.email}"
        expect(subject[:shareholder_groups]).to eq(
          [{
            owners: vessel.owners.map(&:details),
            group_member_keys: [owner_key],
            shares_held: 10 }])
      end
    end
  end

  context "#ec_no" do
    subject { vessel.ec_no }

    context "for a fishing vessel" do
      let(:vessel) { create(:fishing_vessel) }

      it { expect(subject).to eq("GBR000#{vessel.reg_no}") }

      context "when the vessel has no reg_no" do
        before { allow(vessel).to receive(:reg_no).and_return(nil) }

        it { expect(subject).to be_blank }
      end
    end

    context "for a non-fishing vessel" do
      let(:vessel) { create(:pleasure_vessel) }

      it { expect(subject).to be_blank }
    end
  end

  context "#communication_recipients" do
    let(:vessel) { create(:registered_vessel) }
    let(:owners) { [vessel.owners.first.name] }
    let(:agent) { vessel.agent.name }
    let(:managers) { vessel.managers.map(&:name) }
    let(:charter_parties) { vessel.charter_parties.map(&:name) }
    let(:representative) { vessel.representative.name }

    before do
      vessel.owners.create(name: "ZZ_NOT_RETRIEVED")
    end

    subject { vessel.communication_recipients }

    it do
      expect(subject.map(&:name)).to match(
        [owners + [agent] + managers + charter_parties + [representative]]
          .flatten.sort
      )
    end

    it "does not include people without an address" do
      expect(subject.map(&:name)).not_to include("ZZ_NOT_RETRIEVED")
    end
  end
end
