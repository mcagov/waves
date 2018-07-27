require "rails_helper"

xdescribe "User views Part 4 fishing submission", type: :feature, js: true do
  before do
    visit_name_approved_part_4_fishing_submission
  end

  scenario "UI Elements" do
    expect_safety_certificate_warning(true)
    expect_ec_no(true)
    expect_charterers(true)
    expect_mortgages(false)
    expect_port_no_fields(true)
    expect_service_description_fields(true)
    expect_smc_fields(false)
    expect_last_registry_fields(false)
    expect_underlying_registry_fields(true)
    expect_extended_engine_fields(true)
    expect_extended_owner_fields(true)
    expect_managing_owner_fields(false)
    expect_shareholding(false)
    expect_owner_declarations(false)
    expect_payments_tab(true)
  end
end
