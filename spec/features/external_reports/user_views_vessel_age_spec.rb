require "rails_helper"

describe "User views Vessel Age reports", js: true do
  before do
    create(
      :registered_vessel,
      keel_laying_date: "1989",
      vessel_category: "BARGE",
      gross_tonnage: 100,
      imo_number: "IMO1",
      reg_no: "SSR12345",
      name: "BOB",
      year_of_build: Date.today.year - 6)

    create(
      :registered_vessel,
      vessel_category: "BARGE",
      gross_tonnage: 50,
      year_of_build: Date.today.year - 12)

    login_to_reports
    visit admin_report_path(:vessel_age)
  end

  scenario "in general" do
    select("Part III", from: "Part of Register")
    click_on("Apply Filter")

    within("#results") do
      col = find_all("tr td")
      within(col[1]) { expect(page).to have_text("2") }
      within(col[2]) { expect(page).to have_text("9.0") }
      within(col[3]) { expect(page).to have_text("150.0") }
      within(col[0]) { click_on("BARGE") }
    end

    expect_filter_fields(false)
    expect_link_to_export_or_print(true)
    expect(page).to have_css("h1", text: "Vessel Age: BARGE")

    within("#results") do
      col = find_all("tr td")
      within(col[0]) { expect(page).to have_text("BOB") }
      within(col[1]) { expect(page).to have_text("Part III") }
      within(col[2]) { expect(page).to have_text("IMO1") }
      within(col[3]) { expect(page).to have_text("SSR12345") }
      within(col[4]) { expect(page).to have_text("6.0") }
      within(col[5]) { expect(page).to have_text("100.0") }
      within(col[6]) { expect(page).to have_text((Date.today.year - 6).to_s) }
    end
  end
end
