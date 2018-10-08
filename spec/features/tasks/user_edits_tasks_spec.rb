require "rails_helper"

describe "User edits tasks" do
  before do
    Timecop.travel(Time.new(2016, 6, 18))
    create(:demo_service)
    create(:subsequent_only_service)
    @submission = create(:submission)
    login_to_part_3
    visit submission_path(@submission)
    within("#services") { click_on("£25.00") }
  end

  after do
    Timecop.return
  end

  scenario "removing" do
    within("#submission_tasks") do
      click_on(remove_task_link_text)
    end

    expect(Submission::Task.count).to eq(0)
  end

  scenario "editing" do
    within("#submission_tasks") do
      click_on("Edit")
    end

    select("Premium", from: "Service Level")
    fill_in("Price", with: "100")
    fill_in("Start Date", with: "20/06/2016")
    click_on("Save")

    within("#submission_tasks") do
      expect(page).to have_css(".service_level", text: "Premium")
      expect(page).to have_css(".formatted_price", text: "100.00")
      expect(page).to have_css(".start_date", text: "20/06/2016")
    end
  end

  scenario "confirming and reviewing" do
    within("#submission_tasks") do
      expect(page).to have_css(".service_name", text: "Demo Service")
      expect(page).to have_css(".service_level", text: "Standard")
      expect(page).to have_css(".formatted_price", text: "25.00")
      expect(page).to have_css(".start_date", text: "18/06/2016")
    end

    click_on(confirm_tasks_link_text)
    expect(page).to have_current_path(unattached_payments_finance_payments_path)

    visit(submission_path(Submission.last))
    within("#summary") do
      expect(page).to have_css(".payment_due", text: "25.00")
      expect(page).to have_css(".payment_received", text: "0.00")
      expect(page).to have_css(".balance", text: "-25.00")
    end

    within("#submission_tasks") do
      expect(page).not_to have_text(confirm_tasks_link_text)
      expect(page).not_to have_text(remove_task_link_text)
    end
  end

  scenario "when the service does not exist" do
    within("#services") do
      expect(page).to have_css(".subsequent_price", text: "n/a")
    end
  end

  scenario "adding a task with a subsequent_price" do
    within("#services") { click_on("£15.00") }

    within("#submission_tasks") do
      expect(page).to have_css(".service_name", text: "Subsequent Service")
      expect(page).to have_css(".service_level", text: "Standard")
      expect(page).to have_css(".formatted_price", text: "15.00")
    end
  end
end

def confirm_tasks_link_text
  "Confirm Tasks"
end

def remove_task_link_text
  "Remove"
end
