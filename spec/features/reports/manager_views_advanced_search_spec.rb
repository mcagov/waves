require "rails_helper"

describe "Manager views advanced search", js: true do
  before do
    login_to_reports
    click_on("Advanced Search")
  end

  scenario "selecting the search criteria" do
    expect(page).to have_field("Vessel Name")

    # remove the vessel name field
    name_fields = "#fields_vessel_name"
    within(name_fields) do
      find(:css, "a.hide_search_criteria").trigger("click")
    end
    expect(page).not_to have_css(name_fields)

    # restore the vessel name field and add the gross tonnage field
    within("#filter_vessel") do
      find_field("add_criteria[show_vessel]").select("Vessel Name")
      find_field("add_criteria[show_vessel]").select("Gross Tonnage")
    end

    name_operator = "filter[vessel[name_operator]]"
    name_field = "filter[vessel][name]"
    gt_operator = "filter[vessel[gross_tonnage_operator]]"

    # check that the datatypes set the expected operators
    find_field(name_operator).select("Excludes")
    find_field(name_field).set("Bob")
    find_field(gt_operator).select("Greater than")

    # ensure that the selection persists when the form is submitted
    click_on("Apply Filter")
    expect(page).to have_select(name_operator, selected: "Excludes")
    expect(page).to have_field(name_field, with: "Bob")
    expect(page).to have_select(gt_operator, selected: "Greater than")
  end
end
