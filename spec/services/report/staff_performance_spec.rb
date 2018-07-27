require "rails_helper"

describe Report::StaffPerformance do
  context "in general" do
    before do
      create(:completed_submission)
    end

    let(:filters) { { part: :part_3 } }

    subject { described_class.new(filters) }

    it "has a title" do
      expect(subject.title).to eq("Staff Performance")
    end

    it "has some filter_fields" do
      expect(subject.filter_fields).to eq([:filter_part, :filter_date_range])
    end

    it "has some headings" do
      headings = [:task_type, :total_transactions, :top_performer]
      expect(subject.headings).to eq(headings)
    end

    it "has a date range label" do
      expect(subject.date_range_label).to eq("Application Received")
    end

    it "has one result for each task type" do
      expect(subject.results.length).to eq(DeprecableTask.all_task_types.length)
    end

    it "has the expected output for a new registration" do
      new_reg = ["New Registration", 1, "#{Submission.last.claimant} (1)"]
      expect(subject.results.map(&:data_elements)).to include(new_reg)
    end

    it "has the application_type as a sub_report_filter" do
      new_reg = { task: :new_registration }
      expect(subject.results.map(&:sub_report_filters)).to include(new_reg)
    end
  end
end
