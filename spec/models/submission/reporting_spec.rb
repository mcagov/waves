require "rails_helper"

describe Submission::Reporting do
  describe "flag_in/out" do
    let!(:new_reg) { create(:submission, application_type: :new_registration) }
    let!(:closure) { create(:assigned_closure_submission) }

    context ".flag_in" do
      subject { Submission.flag_in }

      it "retrieves the new registration" do
        expect(subject).to eq([new_reg])
      end
    end

    context ".flag_out" do
      subject { Submission.flag_out }

      it "retrieves the closure" do
        expect(subject).to eq([closure])
      end
    end
  end

  describe "merchant/fishing vessels" do
    let!(:fishing) { create(:fishing_submission) }
    let!(:p4_fishing) { create(:part_4_fishing_submission) }
    let!(:merchant) { create(:merchant_submission) }
    let!(:p4_merchant) { create(:part_4_merchant_submission) }

    context ".fishing_vessels" do
      subject { Submission.fishing_vessels }

      it do
        expect(subject).to match_array([fishing, p4_fishing])
      end
    end

    context ".merchant_vessels" do
      subject { Submission.merchant_vessels }

      it do
        expect(subject).to match_array([merchant, p4_merchant])
      end
    end
  end

  describe "by register length" do
    let!(:under_15m) do
      create(:submission,
             changeset: { vessel_info: { register_length: 12.0 } })
    end

    let!(:between_15m_24m) do
      create(:submission,
             changeset: { vessel_info: { register_length: 16 } })
    end

    let!(:over_24m) do
      create(:submission,
             changeset: { vessel_info: { register_length: "44" } })
    end

    context ".under_15m" do
      it { expect(Submission.under_15m).to eq([under_15m]) }
    end

    context ".between_15m_24m" do
      it { expect(Submission.between_15m_24m).to eq([between_15m_24m]) }
    end

    context ".over_24m" do
      it { expect(Submission.over_24m).to eq([over_24m]) }
    end
  end
end
