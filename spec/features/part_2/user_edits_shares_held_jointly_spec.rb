require "rails_helper"

xdescribe "User edits shares held jointly", js: :true do
  before do
    visit_name_approved_part_2_submission
    click_on("Owners & Shareholding")

    @owner_name = Declaration.last.owner.name
    @second_owner_name =
      create(:declaration, submission: Submission.last).owner.name

    click_on("Add Group of Joint Shareholders")
    select(@owner_name, from: "Owner Name")
    click_on("Add Owner to New Group")
  end

  scenario "adding owners to a group of shareholders" do
    click_on(add_owner_to_group_text)
    within(".modal.fade.in") do
      select(@second_owner_name, from: "Owner Name")
      click_on("Add Owner to Group")
    end

    within("#shares_held_jointly") do
      expect(page).to have_css(".owner_name", text: @second_owner_name)
    end

    expect(page).not_to have_link(add_owner_to_group_text)
  end

  scenario "removing an owner from a group" do
    within("#shares_held_jointly") do
      expect(page).to have_text(@owner_name)
      click_on("remove")
    end

    within("#shares_held_jointly") do
      expect(page).not_to have_text(@owner_name)
    end
    expect(Declaration::Group.count).to eq(0)
  end

  scenario "editing the number of shares" do
    expect(page).to have_css("#total_shares", text: "allocated: 64")

    within("#shares_held_jointly") { click_on("0") }

    within(".modal-content") do
      find("#declaration_group_shares_held").set("16")
      click_on("Save")
    end

    expect(page).to have_css("#total_shares", text: "allocated: 80")
  end
end

def add_owner_to_group_text
  "Add Owner to Group"
end
