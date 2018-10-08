require "rails_helper"

describe "User views Part 1 submission", type: :feature, js: true do
  scenario "UI elements" do
    visit_claimed_task(
      service: create(:service, :update_registry_details),
      submission: create(:submission, :part_1_vessel))

    expect_safety_certificate_warning(false)
    expect_ec_no(false)
    expect_charterers(false)
    expect_mortgages(true)
    expect_port_no_fields(false)
    expect_last_registry_fields(true)
    expect_underlying_registry_fields(false)
    expect_service_description_fields(false)
    expect_smc_fields(true)
    expect_extended_engine_fields(false)
    expect_extended_owner_fields(false)
    expect_managing_owner_fields(true)
    expect_shareholding(true)
    expect_owner_declarations(true)
    expect_payments_tab(true)
  end

  scenario "Name Approval page" do
    visit_claimed_task(
      service: create(:service, :update_registry_details),
      submission: create(:submission, part: :part_1))

    expect_port_no_fields(false)
    expect_payments_tab(true)
  end
end
