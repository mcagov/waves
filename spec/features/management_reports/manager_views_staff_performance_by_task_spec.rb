require "rails_helper"

xdescribe "Manager views staff performance by task", js: true do
  before do
    @submission = create(:completed_submission)
    login_to_reports

    click_on("Staff Performance by Task")
  end

  scenario "filtering by task" do
    expect(find("#filter_task").value.to_sym).to eq(:all_tasks)

    filtered_task_result = @submission.claimant
    within("#results") { expect(page).to have_text(filtered_task_result) }

    select("Change of Vessel details", from: "Task Type")
    click_on("Apply Filter")

    within("#results") { expect(page).not_to have_text(filtered_task_result) }

    select("New Registration", from: "Task Type")
    click_on("Apply Filter")

    within("#results") { expect(page).to have_text(filtered_task_result) }
  end
end
