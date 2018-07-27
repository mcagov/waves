require "rails_helper"

xdescribe "Manager views section notice report", js: true do
  before do
    create(:registered_vessel) # should not appear in the report

    @vessel_a = create(:registered_vessel, name: "30 day issued")
    @vessel_a.update_attribute(:frozen_at, Time.zone.now)
    @vessel_a.issue_section_notice!
    Register::SectionNotice.create(noteable: @vessel_a, subject: "REG 51")

    @vessel_b = create(:registered_vessel, name: "7 day issued")
    @vessel_b.update_attribute(:frozen_at, Time.zone.now)
    @vessel_b.issue_section_notice!
    @vessel_b.issue_termination_notice!
    Register::SectionNotice.create(noteable: @vessel_b, subject: "REG 52")

    login_to_reports
    click_on("Section Notices")
  end

  scenario "in general" do
    expect_link_to_export_or_print(true)

    page.all("table tr") do |tr|
      within(tr[0]) do
        expect(page).to have_css("h1", text: "Reports: Section Notices")
        expect(page).to have_css("th", text: "Name")
        expect(page).to have_css("th", text: "Official No")
        expect(page).to have_css("th", text: "Section Notice Issue Date")
        expect(page).to have_css("th", text: "Section Notice Issue Date + 30")
        expect(page).to have_css("th", text: "Regulation Reference")
        expect(page).to have_css("th", text: "Termination Notice Issue Date")
        expect(page).to have_css("th", text: "Status")
      end

      within(tr[1]) do
        expect(page).to have_text("REG 51")
      end

      within(tr[2]) do
        expect(page).to have_text("REG 52")
      end
    end

    expect(page).to have_css("tr", count: 3)
  end

  scenario "linking to a vessel page" do
    within("#results") { click_on(@vessel_a.name) }
    expect(page).to have_current_path(vessel_path(@vessel_a))
  end
end
