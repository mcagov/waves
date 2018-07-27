require "rails_helper"

xfeature "User declares a submission", type: :feature, js: true do
  let!(:submission) { create(:incomplete_submission) }
  let!(:bob) { create(:user, name: "Bob") }

  before do
    login_to_part_3(bob)
    visit submission_path(submission)
  end

  scenario "uploading a completed form" do
    click_on("Owners")
    click_on("Complete Declaration")

    click_on("Owners")
    expect(page).to have_text("Completed by Bob")
  end
end
