require "rails_helper"

xdescribe "User views Part 4 submission", type: :feature, js: true do
  scenario "UI elements" do
    visit_name_approved_part_4_submission
    expect_safety_certificate_warning(false)
    expect_ec_no(false)
    expect_charterers(true)
    expect_mortgages(false)
    expect_port_no_fields(false)
    expect_service_description_fields(false)
    expect_smc_fields(true)
    expect_last_registry_fields(false)
    expect_underlying_registry_fields(true)
    expect_extended_engine_fields(false)
    expect_extended_owner_fields(false)
    expect_managing_owner_fields(false)
    expect_shareholding(false)
    expect_owner_declarations(false)
    expect_payments_tab(true)
  end

  scenario "Name Approval page" do
    visit_assigned_part_4_submission
    expect_port_no_fields(false)
  end

  scenario "tabs" do
    visit_name_approved_part_4_submission
    expect_mortgages(false)
    expect_managers(true)
  end
end
