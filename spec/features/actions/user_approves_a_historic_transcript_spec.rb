require "rails_helper"

xfeature "User approves a historic transcript", type: :feature, js: true do
  before do
    submission =
      create(:assigned_submission,
             application_type: :historic_transcript,
             vessel_reg_no: create(:registered_vessel).reg_no)

    login_to_part_3(submission.claimant)
    visit submission_path(submission)
    expect_edit_application_button(false)
    expect_restricted_submission(true)
    expect_certificates_and_documents(false)

    click_link(
      "Issue Historic Transcript of Registry", href: "#approve-application")
  end

  scenario "in general" do
    within(".modal-content") do
      click_button("Issue Historic Transcript of Registry")
    end

    expect(page).to have_css("h1", text: "Historic Transcript of Registry")
    pdf_window = window_opened_by do
      click_on("Print Historic Transcript")
    end

    within_window(pdf_window) do
      expect(page).to have_text("%PDF")
    end
  end

  scenario "attaching transcript to the email" do
    within(".modal-content") do
      check "Send a copy of the Transcript by email"
      click_button("Issue Historic Transcript of Registry")
    end

    expect(page).to have_text("The applicant has been notified via email")
    expect(Notification::ApplicationApproval.last.attachments)
      .to match(/historic_transcript/)
  end
end
