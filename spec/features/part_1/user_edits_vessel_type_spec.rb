require "rails_helper"

xdescribe "User edits vessel type", js: :true do
  scenario "in general" do
    visit_name_approved_part_1_submission

    select("DREDGER", from: "Vessel Category")
    expect(page).to have_css(".vessel_type_label", text: "Type of DREDGER")

    select("OIL TANKER", from: "Vessel Category")
    expect(page).to have_css(".vessel_type_label", text: "Type of OIL TANKER")
  end
end
