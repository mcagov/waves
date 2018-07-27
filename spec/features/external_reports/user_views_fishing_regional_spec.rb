require "rails_helper"

xdescribe "User views fishing regional reports", js: true do
  before do
    login_to_reports
    visit admin_report_path(:maib)
    click_on("Fishing Regional")

    find("#filter_date_start").set("01/01/2017")
    find("#filter_date_end").set("31/03/2017")
    click_on("Apply Filter")
  end

  scenario "in general" do
    expect_link_to_export_or_print(false)

    within("#results") { click_on("Download") }

    expect(page.response_headers["Content-Type"]).to match("application/xls")
    expect(page.text).to match("Worksheet ss:Name=\"Fishing Regional Report\"")
  end
end
