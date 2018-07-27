require "rails_helper"

xdescribe "User issues a 7 Day Notice", type: :feature, js: true do
  scenario "when a 30 day section notice has been issued" do
    login_to_part_3
    vessel = create(:registered_vessel)
    vessel.issue_section_notice!
    Register::SectionNotice.create(noteable: vessel)

    # set the SectionNotice#created_at to simulate
    # the reg officer workflow
    Register::SectionNotice.last.update_columns(
      created_at: 20.days.ago, updated_at: 20.days.ago)

    visit vessel_path(vessel)

    click_on("Registrar Tools")
    click_on(notice_of_termination_link)

    expect(page).to have_text("Task Complete")

    vessel = Register::Vessel.last
    expect(vessel.registration_status).to eq(:frozen)
    expect(vessel).to be_termination_notice_issued

    pdf_window = window_opened_by do
      click_on("Print 7 Day Notice of Termination")
    end

    within_window(pdf_window) do
      expect(page).to have_text("%PDF")
    end

    # check that the section notice has been updated
    section_notice = Register::SectionNotice.last
    expect(section_notice.updated_at).to be > 1.day.ago

    creates_a_work_log_entry("Submission", :termination_notice)
  end

  scenario "when a 30 day section notice has not been generated" do
    visit_registered_vessel
    click_on("Registrar Tools")
    expect(page).not_to have_link(notice_of_termination_link)
  end
end

def notice_of_termination_link
  "Registration Closure: 7 Day Notice of Termination"
end
