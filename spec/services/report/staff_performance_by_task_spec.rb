require "rails_helper"

describe Report::StaffPerformanceByTask do
  context "in general" do
    before do
      create(:completed_submission)
    end

    let(:filters) { { application_type: :new_registration } }

    subject { described_class.new(filters) }

    it "has a title" do
      expect(subject.title).to eq("Staff Performance by Task")
    end

    it "has some filter_fields" do
      expect(subject.filter_fields)
        .to eq([:filter_task, :filter_part, :filter_date_range])
    end

    it "has a date range label" do
      expect(subject.date_range_label).to eq("Application Received")
    end

    it "has some headings" do
      headings =
        [:staff_member, :online_applications, :paper_applications, :total]
      expect(subject.headings).to eq(headings)
    end
  end
end
