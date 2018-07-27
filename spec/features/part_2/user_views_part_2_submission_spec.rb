require "rails_helper"

xdescribe "User views Part 2 submission", type: :feature, js: true do
  scenario "UI elements" do
    visit_name_approved_part_2_submission
    expect_safety_certificate_warning(true)
    expect_ec_no(true)
    expect_charterers(false)
    expect_mortgages(true)
    expect_port_no_fields(true)
    expect_last_registry_fields(true)
    expect_underlying_registry_fields(false)
    expect_service_description_fields(true)
    expect_smc_fields(false)
    expect_extended_engine_fields(true)
    expect_extended_owner_fields(true)
    expect_managing_owner_fields(true)
    expect_shareholding(true)
    expect_notes_tab(true)
    expect_owner_declarations(true)
    expect_payments_tab(true)
  end

  scenario "Name Approval page" do
    visit_assigned_part_2_submission
    expect_port_no_fields(true)
  end
end
