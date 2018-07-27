require "rails_helper"

xdescribe "User views work logs", type: :feature do
  scenario "in general" do
    3.times { create(:work_log) }
    login_to_part_3

    visit reports_work_logs_path
    expect(page).to have_css("#work_logs tbody tr", count: 3)
  end
end
