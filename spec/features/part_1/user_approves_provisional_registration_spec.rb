require "rails_helper"

xdescribe "User approves provisional registration", js: :true do
  before "in general" do
    visit_name_approved_part_1_provisional_submission

    click_on("Save Details")
    click_on("Complete Provisional Registration")
    click_on("Provisionally Register Vessel")

    expect(page).to have_text("provisionally registered on Part I")
  end

  scenario "printing the certificate" do
    pdf_window = window_opened_by do
      click_on("Print Provisional Certificate of Registry")
    end

    within_window(pdf_window) do
      expect(page).to have_text("%PDF")
    end
  end

  scenario "printing the cover letter" do
    pdf_window = window_opened_by do
      click_on("Print Cover Letter")
    end

    within_window(pdf_window) do
      expect(page).to have_text("%PDF")
    end
  end
end
