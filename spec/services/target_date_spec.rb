require "rails_helper"

describe TargetDate do
  context "#calculate" do
    let(:start_date) { Date.civil(2016, 3, 24) }
    let(:target_date_standard) { Date.civil(2016, 4, 8) }
    let(:target_date_premium) { Date.civil(2016, 3, 30) }
    let(:service) { create(:service) }

    subject { described_class.new(start_date, service_level, service) }

    context ":standard service_level" do
      let(:service_level) { :standard }

      it "is 10 working days" do
        expect(subject.calculate).to eq(target_date_standard)
      end
    end

    context ":premium service_level" do
      let(:service_level) { :premium }

      it "is 3 working days" do
        expect(subject.calculate).to eq(target_date_premium)
      end
    end
  end

  context ".for_task" do
    let(:task) { create(:submission_task) }

    before do
      dbl_target_date = double(TargetDate, calculate: 99)

      expect(described_class)
        .to receive(:new)
        .with(task.start_date, task.service_level, task.service)
        .and_return(dbl_target_date)
    end

    it { expect(described_class.for_task(task)).to eq(99) }
  end

  context ".days_away" do
    before do
      Timecop.freeze(Time.local(2017, 12, 21, 10, 10, 0))
    end

    after do
      Timecop.return
    end

    subject { described_class.days_away(the_date) }

    context do
      let(:the_date) { 1.day.from_now }
      it { expect(subject).to eq("1 day away") }
    end

    context do
      let(:the_date) { 7.days.from_now }
      it { expect(subject).to eq("3 days away") }
    end

    context do
      let(:the_date) { 1.hour.ago }
      it { expect(subject).to eq("Today") }
    end

    context do
      let(:the_date) { Date.new(2017, 12, 14) }
      it { expect(subject).to eq("5 days ago") }
    end

    context do
      let(:the_date) { nil }
      it { expect(subject).to eq("") }
    end
  end
end
