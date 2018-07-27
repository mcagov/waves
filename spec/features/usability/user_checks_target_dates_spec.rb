require "rails_helper"

describe "User checks target dates" do
  scenario "in its simplest form" do
    login_to_part_3
    visit admin_target_dates_path
    expect(page).to have_css("h1", text: "Target Date Calculator")

    select("31", from: "start_date_day")
    select("October", from: "start_date_month")
    select("2019", from: "start_date_year")

    click_on("Calculate")
    expect(find_field("start_date_day").value).to eq "31"
    expect(find_field("start_date_month").value).to eq "10"
    expect(find_field("start_date_year").value).to eq "2019"

    expect(page).to have_text("1 working day away: 31/10/2019")
    expect(page).to have_text("3 working days away: 04/11/2019")
    expect(page).to have_text("10 working days away: 13/11/2019")
  end
end
