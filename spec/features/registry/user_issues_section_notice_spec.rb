require "rails_helper"

xdescribe "User issues a 30 day section notice", type: :feature, js: true do
  scenario "in general" do
    visit_registered_vessel

    click_on("Registrar Tools")
    click_on("Registration Closure: 30 Day Section Notice")

    within("#section-notice") do
      select("56(1)(b)", from: "Regulation/Reason")
      fill_in("Evidence required", with: "Some text")
      find(:css, ".submit_issue_section_notice").trigger("click")
    end

    expect(page).to have_text("Task Complete")

    vessel = Register::Vessel.last
    expect(vessel.registration_status).to eq(:frozen)
    expect(vessel).to be_section_notice_issued

    section_notice = Register::SectionNotice.last
    expect(section_notice.subject).to have_text("56(1)(b)")
    expect(section_notice.content).to eq("Some text")

    pdf_window = window_opened_by do
      click_on("Print 30 Day Section Notice")
    end

    within_window(pdf_window) do
      expect(page).to have_text("%PDF")
    end

    creates_a_work_log_entry("Submission", :section_notice)
  end
end
