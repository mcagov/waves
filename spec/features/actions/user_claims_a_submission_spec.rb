require "rails_helper"

xfeature "User claims a task", type: :feature, js: true do
  before do
    create(:unclaimed_submission_task)
    login_to_part_3

    click_link("Unclaimed Tasks")
  end

  scenario "claim and unclaim a submission" do
    within("tr.task") { click_on("Claim") }
    expect(page).not_to have_css("tr.task")

    click_link("My Tasks")
    within("tr.task") { click_on("Unclaim") }
    expect(page).not_to have_css("tr.task")
  end

  scenario "claim a task from the task page" do
    within("tr.task") { click_on("Boaty Mc") }

    click_on("Claim")
    expect(page)
      .to have_css(".alert-info", text: "successfully claimed this task")
  end
end
