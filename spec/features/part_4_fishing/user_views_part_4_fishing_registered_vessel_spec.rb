require "rails_helper"

describe "User views Part 4 fishing vessel", type: :feature, js: true do
  before do
    @vessel = create(:part_4_fishing_vessel)
    login_to_part_4
    visit vessels_path
    click_on(@vessel.name.upcase)
  end

  scenario "UI Elements" do
    expect_mortgages(false)
    expect_port_no(true)
  end
end
