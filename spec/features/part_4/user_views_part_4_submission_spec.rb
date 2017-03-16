require "rails_helper"

describe "User views Part 4 submission", type: :feature, js: true do
  before do
    visit_name_approved_part_4_submission
  end

  scenario "UI Elements" do
    expect_mortgages(false)
    expect_port_no(false)
  end

  scenario "don't expect_port_no on name approval page"
end
