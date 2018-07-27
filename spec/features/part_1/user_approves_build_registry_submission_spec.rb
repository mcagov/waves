require "rails_helper"

xdescribe "User approves a submission that builds the registry", js: :true do
  before do
    visit_name_approved_part_1_submission
    click_on("Save Details")
    click_on("Complete")
    click_on("Register Vessel")
  end

  scenario "generating an Issue CSR submission from the approval page" do
    click_on("Issue CSR")
    expect(page).to have_css("h1", text: "Issue CSR")
  end
end
