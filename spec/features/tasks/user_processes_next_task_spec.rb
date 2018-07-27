require "rails_helper"

feature "User processes next task", type: :feature, js: true do
  before do
    create(:unclaimed_submission_task)
    login_to_part_3
  end

  scenario "clicking Process Next Task" do
    click_on("My Tasks")
    click_on("Process Next Task")
    click_on("Get More Work")
    expect(page).to have_css("h1", text: "Unclaimed Tasks")

    click_on("Claim")
    click_on("Process Next Task")
    expect(page).to have_css("h1", text: "Demo Service")
  end
end
