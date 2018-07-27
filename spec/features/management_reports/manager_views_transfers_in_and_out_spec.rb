require "rails_helper"

xdescribe "Manager views report: transfers in and out", js: true do
  before do
    @transfer_in = create(:completed_submission)
    @transfer_in.line_items.create(
      fee: build(:fee, task_variant: :transfer_from_bdt))

    @transfer_out = create(:completed_submission)
    @transfer_out.line_items.create(
      fee: build(:fee, task_variant: :transfer_to_bdt))

    login_to_reports

    click_on("Transfers In/Out")

    find("#filter_date_start").set(1.year.ago.to_s)
    find("#filter_date_end").set(1.year.from_now.to_s)
    click_on("Apply Filter")
  end

  scenario "registry (transfer_in)" do
    expect_link_to_export_or_print(true)

    expect(page).to have_css("h1", text: "Reports: Transfers In/Out")

    page.all("table tr") do |tr|
      within(tr[0]) do
        expect(page).to have_css("th", text: "Name")
        expect(page).to have_css("th", text: "IMO Number")
        expect(page).to have_css("th", text: "Gross Tonnage")
        expect(page).to have_css("th", text: "Transfer date")
        expect(page).to have_css("th", text: "Status")
      end
    end
    page.all("table tr") do |tr|
      vessel = @transfer_in.registered_vessel
      within(tr[1]) do
        expect(page).to have_css("th", text: vessel.name)
        expect(page).to have_css("th", text: vessel.imo_number)
        expect(page).to have_css("th", text: vessel.gross_tonnage)
        expect(page).to have_css("th", text: @transfer_in.completed_at.to_s)
        expect(page).to have_css("th", text: "Transfer In")
      end
    end
  end

  scenario "closure (transfer_out)" do
    select("Closure (Transfer Out)", from: "Transfer Type")
    click_on("Apply Filter")

    page.all("table tr") do |tr|
      vessel = @transfer_out.registered_vessel
      within(tr[1]) do
        expect(page).to have_css("th", text: vessel.name)
        expect(page).to have_css("th", text: vessel.imo_number)
        expect(page).to have_css("th", text: vessel.gross_tonnage)
        expect(page).to have_css("th", text: @transfer_out.completed_at.to_s)
        expect(page).to have_css("th", text: "Transfer Out")
      end
    end

    within("#results") { click_on(@transfer_out.vessel.name) }
    expect(page)
      .to have_current_path(vessel_path(@transfer_out.registered_vessel))
  end
end
