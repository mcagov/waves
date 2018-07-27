require "rails_helper"

describe "Service" do
  let(:service) { create(:demo_service) }

  context "#standard_price(part)" do
    it { expect(service.price_for(:part_1, :standard)).to eq(12400) }
    it { expect(service.price_for(:part_2, :standard)).to be_blank }
    it { expect(service.price_for(:part_3, :standard)).to eq(2500) }
    it { expect(service.price_for(:part_4, :standard)).to eq(12400) }
  end

  context "#premium_price(part)" do
    it { expect(service.price_for(:part_1, :premium)).to eq(30400) }
    it { expect(service.price_for(:part_2, :premium)).to be_blank }
    it { expect(service.price_for(:part_3, :premium)).to eq(7500) }
    it { expect(service.price_for(:part_4, :premium)).to eq(30400) }
  end

  context "#subsequent_price(part)" do
    it { expect(service.price_for(:part_1, :subsequent)).to eq(9900) }
    it { expect(service.price_for(:part_2, :subsequent)).to be_blank }
    it { expect(service.price_for(:part_3, :subsequent)).to be_blank }
    it { expect(service.price_for(:part_4, :subsequent)).to be_blank }
  end
end
