require "rails_helper"

describe "Team leader unclaims tasks", type: :feature, js: true do
  before do
    create(:claimed_submission_task)
  end

  scenario "as a team leader" do
    login_to_part_3(create(:team_leader))
    visit("/tasks/team-tasks")
    click_on(unclaim_task_link)
    expect(Submission::Task.last).to be_unclaimed
  end

  scenario "as an operational user" do
    login_to_part_3(create(:operational_user))
    visit("/tasks/team-tasks")
    expect(page).to have_css("h1", text: "Team Tasks")
    expect(page).not_to have_button(unclaim_task_link)
  end
end

def unclaim_task_link
  "Unclaim (Team Leader only)"
end
