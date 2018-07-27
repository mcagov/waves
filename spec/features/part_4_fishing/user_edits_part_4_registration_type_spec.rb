require "rails_helper"

xfeature "User edits part 2 registration_type", type: :feature, js: :true do
  scenario "in general" do
    visit_part_4_new_registration
    expect_port_no_fields(false) # the registration_type is "Commercial"

    select2("Fishing", from: "submission_name_approval_registration_type")
    expect_port_no_fields(true)

    click_on("Validate Name")
    expect_port_no_fields(true)
  end
end
