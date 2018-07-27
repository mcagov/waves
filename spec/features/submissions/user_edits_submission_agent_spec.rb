require "rails_helper"

describe "User edits submission agent", js: true do
  before do
    visit_claimed_task

    click_on "Edit Application"
    click_on("Agent")
  end

  scenario "editing the agent" do
    click_on(Submission.last.agent.name)

    within(".modal.fade.in") { expect_postcode_lookup }
    fill_in("Full Name", with: "ALICE AGENT")
    fill_in("Email Address", with: "alice@example.com")
    fill_in("Phone Number", with: "012345678")

    fill_in("Address 1", with: "A1")
    fill_in("Address 2", with: "A2")
    fill_in("Address 3", with: "A3")
    fill_in("Town or City", with: "Town")
    fill_in("Postcode", with: "POC123")
    select("SPAIN", from: "Country")
    click_on("Save Agent")

    expect(page).to have_link("ALICE AGENT", href: "#")
    expect(page).to have_css(".agent-email", text: "alice@example.com")
    expect(page).to have_css(".agent-phone_number", text: "012345678")
    expect(page)
      .to have_css(".agent-address", text: "A1, A2, A3, TOWN, POC123, SPAIN")
  end

  scenario "removing the agent and replacing" do
    click_on("Remove")
    click_on("Add Agent")
    fill_in("Full Name", with: "ANOTHER AGENT")
    click_on("Save Agent")

    expect(page).to have_link("ANOTHER AGENT", href: "#")
  end
end
