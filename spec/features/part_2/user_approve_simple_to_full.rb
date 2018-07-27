require "rails_helper"

xfeature "User approves a 'Simple to Full' task", type: :feature, js: :true do
  before do
    visit_name_approved_part_2_simple_to_full_submission
  end

  scenario "in general" do
    select("Full", from: "Registration Type")
    click_on("Save Details")
    click_on("Complete Convert Simple Registry to Full Registry")
    within(".modal-content") do
      expect(page).to have_css(".date-pickers-hidden")
    end
    click_on("Convert Simple Registry to Full Registry")

    expect(page).to have_text("registered on Part II of the UK Ship Register")
  end
end
