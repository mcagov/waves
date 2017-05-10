require "rails_helper"

describe "Manager views expiring certificates", js: true do
  before do
    @vessel = create(:registered_vessel, part: :part_2)
    @document = create(:document, noteable: @vessel, expires_at: "20/01/2017")
    login_to_reports

    click_on("Expiring Certificates")
  end

  scenario "in general" do
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

  scenario "linking to a vessel page" do
    within("#results") { click_on(@vessel.name) }
    expect(page).to have_current_path(vessel_path(@vessel))
  end
end
