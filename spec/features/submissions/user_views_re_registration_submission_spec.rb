require "rails_helper"

xfeature "User views re_registration submission", type: :feature, js: true do
  let(:submission) { create(:assigned_re_registration_submission) }

  before do
    login_to_part_3
    visit(submission_path(submission))
  end

  scenario "in general" do
    within("h1") do
      expect(page).to have_content(/Re-Registration .* ID:/)
    end

    within(".submission-vessel") do
      expect(page).to have_css("th", count: 2)
      expect(page).to have_css("th", text: "Submitted Information")
    end
  end
end
