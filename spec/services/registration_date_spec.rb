require "rails_helper"

describe RegistrationDate do
  context ".for" do
    subject { described_class.for(submission, "2012-11-24") }

    context "new registration" do
      let(:submission) { build(:submission) }

      it "sets starts_at to today" do
        expect(subject.starts_at.to_date).to eq(Date.new(2012, 11, 24))
      end

      it "sets ends_at to 5 years ahead" do
        expect(subject.ends_at.to_date).to eq(Date.new(2017, 11, 24))
      end
    end

    context "a provisional_registration" do
      let(:submission) { build(:submission, application_type: :provisional) }

      it "sets starts_at to today" do
        expect(subject.starts_at.to_date).to eq(Date.new(2012, 11, 24))
      end

      it "sets ends_at to 90 days ahead" do
        expect(subject.ends_at.to_date).to eq(Date.new(2013, 2, 22))
      end
    end

    context "a change_vessel" do
      let(:submission) { build(:assigned_change_vessel_submission) }

      it "sets starts_at to today" do
        expect(subject.starts_at.to_date).to eq(Date.new(2012, 11, 24))
      end

      it "sets the ends_at to the vessel's registered_until" do
        expect(subject.ends_at)
          .to eq(submission.registered_vessel.registered_until)
      end
    end
  end

  context ".start_date" do
    subject { described_class.start_date(submission) }

    context "for a new registration" do
      let(:submission) { build(:submission) }

      it "sets starts_at to today" do
        expect(subject.to_date).to eq(Time.zone.today)
      end
    end

    context "for an unregistered_vessel" do
      let!(:submission) do
        create(
          :approvable_submission,
          part: :part_2,
          registered_vessel: build(:unregistered_vessel))
      end

      it "sets starts_at to today" do
        expect(subject.to_date).to eq(Time.zone.today)
      end
    end

    context "for a vessel with an existing registration" do
      let!(:submission) { create(:assigned_re_registration_submission) }

      before do
        submission.registered_vessel
                  .current_registration
                  .update_attribute(:registered_until, registered_until)
      end

      context "when the current reg expires within the next 3 months" do
        let(:registered_until) { 2.months.from_now }

        it "sets starts_at to the previous date of expiry" do
          expect(subject).to eq(registered_until)
        end
      end

      context "when the current reg expires more than three months from now" do
        let(:registered_until) { 4.months.from_now }

        it "sets starts_at to today's date" do
          expect(subject.to_date).to eq(Time.zone.today)
        end
      end
    end
  end
end
