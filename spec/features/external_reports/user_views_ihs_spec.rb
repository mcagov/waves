require "rails_helper"

xdescribe "User views IHS/Fairplay reports", js: true do
  before do
    login_to_reports
    visit admin_report_path(:fishing_regional)
    click_on("IHS/Fairplay")
  end

  scenario "in general" do
    expect_link_to_export_or_print(false)
    within("#results") { click_on("Download") }

    expect(page.response_headers["Content-Type"]).to match("application/xls")
    expect(page.text).to match("Worksheet ss:Name=\"IHS Fairplay\"")
  end
end
