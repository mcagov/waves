require "rails_helper"

xdescribe "Manager views expiring certificates", js: true do
  before do
    @vessel = create(:registered_vessel, part: :part_2)
    @document = create(:document, entity_type: :certificate_of_survey,
                                  noteable: @vessel,
                                  expires_at: "20/01/2017")
    login_to_reports

    click_on("Expiring Certificates")
  end

  scenario "in general" do
    expect_link_to_export_or_print(true)
    expect(page).to have_css("h1", text: "Reports: Expiring Certificates")
    expect(page).to have_css("th", text: "Vessel Name")
    expect(page).to have_css("th", text: "Certificate")
    expect(page).to have_css("th", text: "Expiry Date")
  end

  scenario "filtering by part" do
    part_two_results = @document.entity_type.titleize
    within("#results") { expect(page).to have_text(part_two_results) }

    select("Part I", from: "Part of Register")
    click_on("Apply Filter")

    within("#results") { expect(page).not_to have_text(part_two_results) }

    select("Part II", from: "Part of Register")
    click_on("Apply Filter")

    within("#results") { expect(page).to have_text(part_two_results) }
  end

  scenario "filtering by date range" do
    date_range_result = @document.entity_type.titleize
    expect(page).to have_text(date_range_result)

    find("#filter_date_start").set("21/01/2017")
    find("#filter_date_end").set("22/01/2017")
    click_on("Apply Filter")

    expect(page).not_to have_text(date_range_result)

    find("#filter_date_start").set("20/01/2017")
    find("#filter_date_end").set("22/01/2017")
    click_on("Apply Filter")

    expect(page).to have_text(date_range_result)
  end

  scenario "filtering by document type" do
    document_type_result = @vessel.name
    expect(page).to have_text(document_type_result)

    find("#filter_document_type").set(:bill_of_sale)
    click_on("Apply Filter")

    expect(page).not_to have_text(document_type_result)

    find("#filter_document_type").set("certificate_of_survey")
    click_on("Apply Filter")

    expect(page).to have_text(document_type_result)
  end

  scenario "linking to a vessel page" do
    within("#results") { click_on(@vessel.name) }
    expect(page).to have_current_path(vessel_path(@vessel))
  end
end
