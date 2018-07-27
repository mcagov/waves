require "rails_helper"

xfeature "User approves a closure", type: :feature, js: true do
  before do
    submission = create(:assigned_closure_submission)
    login_to_part_3(submission.claimant)
    visit submission_path(submission)
    expect_edit_application_button(false)
    expect_restricted_submission(true)
    expect_certificates_and_documents(true)

    click_link("Close Registration", href: "#approve-application")
  end

  scenario "in general" do
    within(".modal-content") do
      expect(page).not_to have_field("registration_starts_at")

      select("Failed to renew", from: "Closure Reason")
      fill_in("Closure Date", with: "01/09/2011")
      click_button("Close Registration")
    end

    expect(page).to have_css("h1", text: "Registration Closure")
    expect(page).to have_text("Registration Closure has been approved")

    pdf_window = window_opened_by do
      click_on("Print Current Transcript")
    end

    within_window(pdf_window) do
      expect(page).to have_text("%PDF")
    end
  end

  scenario "checking prepopulaton of reason and entering supporting info" do
    within(".modal-content") do
      expect(find_field("submission_approval_closure_reason").value)
        .to eq("Other")

      expect(find_field("submission_approval_supporting_info").value)
        .to eq("DONT WANT")

      fill_in("Supporting Info", with: "DONT WANT IT")
      click_button("Close Registration")
    end

    expect(page).to have_css("h1", text: "Registration Closure")
    last_registration = Submission.last.registration
    expect(last_registration.description).to eq("Other")
    expect(last_registration.supporting_info).to eq("DONT WANT IT")
  end

  scenario "attaching certificate to the email" do
    within(".modal-content") do
      check "Send a copy of the Transcript by email"
      click_button("Close Registration")
    end

    expect(page).to have_text("The applicant has been notified via email")
    expect(Notification::ApplicationApproval.last.attachments)
      .to match(/current_transcript/)
  end
end
