require "rails_helper"

xdescribe "Manager views staff performance report", js: true do
  before do
    @submission = create(:completed_submission)
    @submission.update_attributes(received_at: "20/01/2017")
    login_to_reports

    click_on("Staff Performance")
  end

  scenario "in general" do
    expect_link_to_export_or_print(true)

    expect(page).to have_css("h1", text: "Reports: Staff Performance")
    expect(page).to have_css("th", text: "Task Type")
    expect(page).to have_css("th", text: "Total Transactions")
    expect(page).to have_css("th", text: "Top Performer")
    expect(page).to have_link("Print")
  end

  scenario "filtering by part" do
    part_three_result = "#{@submission.claimant} (1)"
    within("#results") { expect(page).to have_text(part_three_result) }

    select("Part II", from: "Part of Register")
    click_on("Apply Filter")

    within("#results") { expect(page).not_to have_text(part_three_result) }

    select("Part III", from: "Part of Register")
    click_on("Apply Filter")

    within("#results") { expect(page).to have_text(part_three_result) }
  end

  scenario "filtering by date range" do
    date_range_result = "#{@submission.claimant} (1)"
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

  scenario "downloading the xls version" do
    click_on("Export to Excel")
    sleep 1
    expect(page.response_headers["Content-Type"]).to match("application/xls")
    expect(page.text).to match("Worksheet ss:Name=\"Staff Performance\"")
  end

  scenario "viewing the sub report with an existing filter" do
    select("Part II", from: "Part of Register")
    find("#filter_date_start").set("21/01/2017")
    click_on("Apply Filter")

    within("#results") do
      click_on("Re-Registration")
    end

    expect(find("#filter_task").value).to eq("re_registration")
    expect(find("#filter_part").value).to eq("part_2")
    expect(find("#filter_date_start").value).to eq("21/01/2017")
    expect(page)
      .to have_css("h1", text: "Reports: Staff Performance by Task")
  end
end
