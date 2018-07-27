require "rails_helper"

feature "User toggles task lists", type: :feature, js: true do
  let!(:submission_task) { create(:unclaimed_submission_task) }
  let(:submission) { submission_task.submission }

  scenario "moving a task around the queues" do
    login_to_part_3

    click_on("Unclaimed Tasks")
    expect_page_to_display_task

    click_on("Claim")
    click_on("My Tasks")
    expect_page_to_display_task

    click_on("Team Tasks")
    expect_page_to_display_task

    click_on("Unclaim")
    click_link("Unclaimed Tasks")
    expect_page_to_display_task
  end

  scenario "viewing other parts of the registry" do
    login_to_part_1
    click_on("Unclaimed Tasks")

    expect(page).to have_content("There are no items in this queue")
  end
end

def expect_page_to_display_task # rubocop:disable Metrics/AbcSize
  within("#tasks") do
    expect(page)
      .to have_css(".vessel-name", text: submission.vessel.name)
    expect(page).to have_content("Demo Service")
    expect(page).to have_content(submission_task.ref_no)
    expect(page).to have_content("9 days away")
  end
end
