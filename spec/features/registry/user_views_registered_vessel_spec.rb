require "rails_helper"

describe "User views a registered vessel", type: :feature, js: true do
  before do
    @submission = create(:completed_submission)
    @vessel = @submission.registered_vessel
    login_to_part_3
    visit vessel_path(@vessel)
  end

  scenario "viewing vessel details" do
    click_on("Owners")
    expect(page)
      .to have_css(".owner-name", text: @submission.owners.first.name)

    click_on("Agent")
    expect(page).to have_css(".agent-name", text: @submission.agent)

    click_on("Correspondence")
    expect(page).to have_link("Add Correspondence")
  end

  scenario "adding a note with two attachments" do
    click_on("Notes")
    click_on("Add Note")

    fill_in("Content", with: "Some stuff")
    page.attach_file(
      "note_assets_attributes_0_file", mca_file)
    page.attach_file(
      "note_assets_attributes_1_file", "spec/support/files/mca_test.jpg")
    click_on("Save Note")

    click_on("Notes")
    expect(page).to have_link("mca_test.pdf", href: /mca_test.pdf/)
    expect(page).to have_link("mca_test.jpg", href: /mca_test.jpg/)

    click_on("Some stuff")
    expect(page).to have_css(".modal-body", text: "Some stuff")
  end

  xscenario "linking to the submission page" do
    expect(page).to have_css("h1", text: @submission.vessel.name)

    click_on("Application History")
    click_on("New Registration")

    within("#vessel-name") do
      expect(page).to have_text(@submission.vessel.name)
    end

    expect(page).not_to have_css("#actions")
    expect(page).not_to have_css(".breadcrumb")
  end

  scenario "viewing the registration status" do
    expect(page)
      .to have_css(".registration_status", text: "Registered")

    registration = Registration.last

    registration.update_attributes(registered_until: 1.day.ago)
    visit vessel_path(registration.vessel)
    expect(page)
      .to have_css(".registration_status", text: "Registration Expired")

    registration.update_attributes(closed_at: 1.day.ago)
    visit vessel_path(registration.vessel)
    expect(page)
      .to have_css(".registration_status", text: "Registration Closed")
  end
end
