require "rails_helper"

describe "User edits submission notes", js: true do
  before do
    visit_claimed_task
  end

  scenario "creating a note then editing it" do
    click_on("Notes")
    click_on("Add Note")

    fill_in("Content", with: "Some stuff")
    click_on("Save Note")
    expect(Note.count).to eq(1)

    click_on("Some stuff")
    fill_in("Content", with: "Some edited stuff")
    click_on("Edit Note")

    expect(page).to have_link("Some edited stuff")
    expect(Note.count).to eq(1)
  end
end
