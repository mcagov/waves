require "rails_helper"

describe "User edits submission owners", js: true do
  before do
    visit_claimed_task(
      submission: create(:submission, :part_3_vessel),
      service: create(:service, :update_registry_details))

    click_on "Edit Application"
    click_on("Owners")
  end

  scenario "adding an owner" do
    click_on("Add Individual Owner")

    within(".modal.fade.in") { expect_postcode_lookup }

    fill_in("Owner Name", with: "ALICE NEW OWNER")
    select("SPAIN", from: "Nationality")
    fill_in("Email", with: "alice@example.com")
    fill_in("Phone Number", with: "012345678")

    fill_in("Address 1", with: "Address 1")
    fill_in("Address 2", with: "Address 2")
    fill_in("Address 3", with: "Address 3")
    fill_in("Town or City", with: "Town")
    fill_in("Postcode", with: "POC123")

    within(".declaration_declaration_signed") { choose("Yes") }
    click_on("Save Individual Owner")

    expect(page).to have_link("ALICE NEW OWNER", href: "#")
    expect(page).to have_css(".owner-email", text: "alice@example.com")
    expect(page).to have_css(".owner-phone_number", text: "012345678")
    expect(page).to have_css(".owner-nationality", text: "SPAIN")

    inline_address =
      "ADDRESS 1, ADDRESS 2, ADDRESS 3, TOWN, UNITED KINGDOM, POC123"
    expect(page).to have_css(".owner-address", text: inline_address)

    alice_declaration = Customer.where(name: "ALICE NEW OWNER").first.parent
    expect(alice_declaration).to be_completed
  end

  scenario "editing an owner" do
    owner_name = Submission.last.owners.last.name
    click_on(owner_name)

    fill_in("Email", with: "edited_alice@example.com")
    click_on("Save Individual Owner")

    click_on(owner_name)
    expect(find_field("Email").value).to eq("edited_alice@example.com")
  end

  scenario "removing an owner" do
    owner_name = Submission.last.registered_vessel.owners.last.name
    expect(page).to have_css(".owner-name", text: owner_name)

    page.accept_confirm { click_on("Remove") }
    expect(page).to have_css(".strike", text: owner_name)
  end
end
