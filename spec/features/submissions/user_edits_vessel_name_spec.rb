require "rails_helper"

describe "User edits vessel name", js: true do
  before do
    visit_claimed_task
    click_on "Edit Application"
  end

  scenario "in general" do
    original_vessel_name = find_field("Approved Vessel Name").value

    first(:link, "Use this name").click

    expect(find_field("Approved Vessel Name").value).to eq("ALT NAME 1")
    expect(find_field("Alternative Vessel Name #1").value)
      .to eq(original_vessel_name)
  end
end
