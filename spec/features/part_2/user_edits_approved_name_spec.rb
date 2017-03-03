require "rails_helper"

feature "User edits part 2 name and PLN", type: :feature, js: :true do
  scenario "for a new_registration" do
    visit_name_approved_part_2_submission
    click_on("Change Name or PLN")
    complete_name_approval_form
  end
end

def complete_name_approval_form
  fill_in("Vessel Name", with: "BOBS BOAT")
  select2("Full", from: "submission_name_approval_registration_type")
  select2("SOUTHAMPTON", from: "submission_name_approval_port_code")
  fill_in("Port Number", with: "99")

  click_on("Validate Name")
  click_on("Approve Name")

  expect(page).to have_current_path(edit_submission_path(Submission.last))

  expect(Submission.last.vessel.name).to eq("BOBS BOAT")
end
