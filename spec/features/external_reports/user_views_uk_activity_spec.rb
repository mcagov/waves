require "rails_helper"

xdescribe "User views UK Activity reports", js: true do
  before do
    login_to_reports
    visit admin_report_path(:fishing_regional)
    click_on("UK Activity")

    find("#filter_date_start").set("01/01/2017")
    find("#filter_date_end").set("31/03/2017")
    click_on("Apply Filter")
  end

  scenario "Merchant Flag in" do
    expect_filter_fields(true)
    expect_link_to_export_or_print(true)

    within("#results") do
      click_on("Merchant Flag in")
    end

    expect_filter_fields(false)
    expect(page)
      .to have_css("h1", text: "Merchant Flag in (01/01/2017 to 31/03/2017)")
  end

  scenario "exporting to excel" do
    click_on("Export to Excel")
    sleep 1
    expect(page.response_headers["Content-Type"]).to match("application/xls")
    expect(page.text).to match("UK Activity: 01/01/2017-31/03/2017")
  end
end
