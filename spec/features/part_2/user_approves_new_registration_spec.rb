require "rails_helper"

xdescribe "User approves new registration", js: :true do
  before "in general" do
    visit_name_approved_part_2_submission

    click_on("Save Details")
    click_on("Complete Registration")
    click_on("Register Vessel")

    expect(page).to have_text("registered on Part II of the UK Ship Register")
  end

  scenario "printing the certificate" do
    pdf_window = window_opened_by do
      click_on("Print Certificate of Registry")
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
