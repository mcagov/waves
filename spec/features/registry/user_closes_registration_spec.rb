require "rails_helper"

xdescribe "User closes a vessel's registration", type: :feature, js: true do
  scenario "By Owner Request" do
    visit_registered_vessel

    click_on("Registrar Tools")
    click_on("Registration Closure: Owner Request")

    expect(page).to have_css(".registration_status", text: "Closed")
    creates_a_work_log_entry("Submission", :registrar_closure)
    WorkLog.delete_all

    click_on("Registrar Tools")
    click_on("Restore Closed Registration")

    expect(page).to have_css(".registration_status", text: "Registered")
    creates_a_work_log_entry("Submission", :registrar_restores_closure)
  end

  scenario "Without Notice" do
    visit_registered_vessel

    click_on("Registrar Tools")
    click_on("Registration Closure: Close Without Notice")

    expect(page).to have_text("The Closure Without Notice has been completed")
    expect(page).to have_link("Print Current Transcript")
    creates_a_work_log_entry("Submission", :forced_closure)

    pdf_window = window_opened_by do
      click_on("Print Cover Letter: Closure Without Notice")
    end

    within_window(pdf_window) do
      expect(page).to have_text("%PDF")
    end
  end
end
