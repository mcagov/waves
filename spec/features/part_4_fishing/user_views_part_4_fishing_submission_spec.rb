require "rails_helper"

describe "User views Part 4 fishing submission", type: :feature, js: true do
  scenario "UI Elements" do
    visit_claimed_task(
      service: create(:service, :update_registry_details),
      submission: create(:submission, :part_4_fishing_vessel))

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
