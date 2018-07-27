require "rails_helper"

xdescribe "User edits submission agent and representative person", js: true do
  before do
    visit_name_approved_part_2_submission
    click_on("Agent & Representative Person")
  end

  scenario "agent" do
    expect(page).to have_css("#agent_list td.agent-name", count: 1)
    expect(page).to have_css("#agent_modal")
  end

  scenario "representative" do
    click_on("Add Representative Person")

    within(".modal.fade.in") do
      expect_postcode_lookup
      fill_in("Name", with: "BOB BOLD")
      fill_in("Phone Number", with: "1234567")
      click_on("Save Representative Person")
    end

    expect(page).not_to have_link("Add Representative Person")
    expect(page).to have_css(".representative-phone_number", text: "1234567")

    click_on("BOB BOLD")
    fill_in("Phone Number", with: "7654321")
    click_on("Save Representative Person")

    expect(page).to have_css(".representative-phone_number", text: "7654321")

    within("#representative") do
      click_on("Remove")
      expect(page).not_to have_css(".representative-name")
      expect(Submission.last.representative.name).to be_blank
    end
  end
end
