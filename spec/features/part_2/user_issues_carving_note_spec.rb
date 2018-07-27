require "rails_helper"

xdescribe "User issues a Carving & Marking Note", js: true do
  scenario "by email" do
    visit_carving_and_marking_ready_submission
    click_on("Certificates & Documents")

    within("#carving_and_marking .status") do
      click_on("Issue Carving & Marking Note")
    end

    within(".modal-content") do
      select("Send via Email", from: "Delivery Method")
      select("All fishing vessels", from: "Template")
      click_on("Issue Carving & Marking Note")
    end

    within("#carving_and_marking") do
      expect(page).to have_css(".delivery_method", text: "Email")
    end

    expect(Notification::CarvingAndMarkingNote.count).to eq(1)
    creates_a_work_log_entry("Submission", :issued_carving_and_marking_note)
  end

  scenario "as a printed page" do
    visit_carving_and_marking_ready_submission
    click_on("Certificates & Documents")

    within("#carving_and_marking .status") do
      click_on("Issue Carving & Marking Note")
    end

    within(".modal-content") do
      select("Print", from: "Delivery Method")
      select("All fishing vessels", from: "Template")
      click_on("Issue Carving & Marking Note")
    end

    pdf_window = window_opened_by do
      click_on("Print Carving & Marking Note")
    end

    within_window(pdf_window) do
      expect(page).to have_text("%PDF")
    end

    creates_a_work_log_entry("Submission", :issued_carving_and_marking_note)
    expect(PrintJob.last).to be_printing
  end

  scenario "when the pre-requisites have not been met" do
    visit_name_approved_part_2_submission
    click_on("Certificates & Documents")

    within("#carving_and_marking .status") do
      expect(page).to have_css(".red", text: "Official Number required")
    end
  end
end
