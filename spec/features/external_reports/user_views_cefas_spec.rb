require "rails_helper"

describe "User views CEFAS reports", js: true do
  before do
    login_to_reports
    visit admin_report_path(:vessel_age)
    click_on("CEFAS")
  end

  scenario "in general" do
    find("#filter_date_start").set("01/01/2017")
    find("#filter_date_end").set("31/03/2017")

    expect_link_to_export_or_print(false)
    click_on("Apply Filter")

    within("#results") { click_on("Download") }

    expect(page.response_headers["Content-Type"]).to match("application/xls")
    expect(page.text).to match("Worksheet ss:Name=\"Open Registrations\"")
  end
end
