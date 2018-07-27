require "rails_helper"

xdescribe "User edits submission for other tasks", js: true do
  scenario "for a change_address" do
    submission = create(:assigned_change_address_submission)
    login_to_part_3(submission.claimant)
    visit edit_submission_path(submission)

    expect(page).to have_css("#vessel_tab fieldset[disabled]")

    click_on("Owners")
    expect(page).not_to have_link("Remove")
    expect(page).not_to have_link("Add Individual Owner")

    click_on(submission.owners.first.name)
    fill_in("Address 1", with: "NEW ADDRESS 1")
    click_on("Save Individual Owner")
    expect(page).to have_css(".owner-address", text: "NEW ADDRESS 1")

    click_on("Save Application")
    expect(page).to have_current_path(submission_path(Submission.last))
  end

  scenario "for a change_vessel" do
    submission = create(:assigned_change_vessel_submission)
    login_to_part_3(submission.claimant)
    visit edit_submission_path(submission)

    fill_in("Approved Vessel Name", with: "NEW BOAT NAME")

    click_on("Owners")
    expect(page).not_to have_link("Remove")
    expect(page).not_to have_link("Add Individual Owner")
    expect(page).not_to have_link(submission.owners.first.name)

    click_on("Save Application")

    within(".submission-vessel") do
      expect(page).to have_css("#vessel-name", text: "NEW BOAT NAME")
    end
  end
end
