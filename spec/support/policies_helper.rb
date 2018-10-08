def expect_field(bln, css, text = "")
  if bln
    expect(page).to have_css(css, text: text)
  else
    expect(page).not_to have_css(css, text: text)
  end
end

def expect_safety_certificate_warning(bln)
  expect_field(bln, "#prompt.alert", "Safety Certificate")
end

def expect_csr_forms(bln)
  expect_field(bln, "#csr_forms-tab")
end

def expect_ec_no(bln)
  expect_field(bln, "#ec-no")
end

def expect_charterers(bln)
  expect_field(bln, "#charterers-tab")
end

def expect_owner_declarations(bln)
  click_on("Owners")
  click_on("Add Individual Owner")
  expect_field(bln, ".owner_declaration_fields")
end

def expect_managers(bln)
  expect_field(bln, "#managers-tab")
end

def expect_shareholding(bln)
  click_on("Owners")
  expect_field(bln, "#shareholding")
end

def expect_mortgages(bln)
  expect_field(bln, "#mortgages-tab")
end

def expect_port_no_fields(bln)
  expect_field(bln, ".port_no_fields")
end

def expect_service_description_fields(bln)
  expect_field(bln, ".service_description_fields")
end

def expect_last_registry_fields(bln)
  expect_field(bln, ".last_registry_fields")
end

def expect_underlying_registry_fields(bln)
  expect_field(bln, ".underlying_registry_fields")
end

def expect_smc_fields(bln)
  expect_field(bln, ".smc_fields")
end

def expect_referral_button(bln)
  expect_field(bln, ".btn-refer-submission")
end

def expect_extended_engine_fields(bln)
  click_on("Engines")
  within("#engines") do
    expect_field(bln, ".extended-engine")
  end
end

def expect_extended_owner_fields(bln)
  click_on("Owners")
  within("#owners_tab") do
    expect_field(bln, "#managed_by")
    expect_field(bln, "#beneficial_owners")
    expect_field(bln, "#directed_by")
  end
end

def expect_managing_owner_fields(bln)
  click_on("Owners")
  within("#owners_tab") do
    expect_field(bln, ".managing_owner")
  end
end

def expect_notes_tab(_bln)
  click_on("Notes")
  within("#notes_tab #notes") { expect(page).to have_link("Add Note") }
end

def expect_payments_tab(bln)
  expect_field(bln, "#payments-tab")
end

def expect_edit_application_button(bln)
  expect_field(bln, "#heading #edit_application")
end

def expect_restricted_submission(bln)
  expect_field(bln, "#restricted")
end

def expect_certificates_and_documents(bln)
  expect_field(bln, "#documents-tab")
  if bln
    click_on("Certificates & Documents")
    expect_field(bln, "#documents")
  end
end
