require "rails_helper"

xfeature "User adds correspondence", type: :feature, js: true do
  scenario "to a submission" do
    visit_assigned_submission
    click_on("Correspondence")
    click_link("Add Correspondence")

    fill_in "Subject", with: "My Subject"
    select "Post", from: "Correspondence Format"
    fill_in "Date Received", with: "12/12/2015"
    fill_in "Content", with: "Hello Bob"
    click_on "Save Correspondence"

    click_on("Correspondence")
    click_on("My Subject")

    expect(page).to have_css("h4", text: "My Subject")
    expect(page).to have_css(".modal-body", text: "Hello Bob")
    click_on("Close")

    within("#notification-list") do
      page.accept_confirm { click_on("Remove") }
    end

    expect(page)
      .to have_css("#flash", text: "correspondence has been removed")
    expect(Correspondence.count).to eq(0)
  end

  scenario "to a vessel" do
    visit_registered_vessel
    click_on("Correspondence")
    click_link("Add Correspondence")

    fill_in "Subject", with: "My Subject"
    select "Post", from: "Correspondence Format"
    fill_in "Date Received", with: "12/12/2015"
    fill_in "Content", with: "Hello Alice"
    click_on "Save Correspondence"

    click_on("Correspondence")
    click_on("My Subject")

    expect(page).to have_css("h4", text: "My Subject")
    expect(page).to have_css(".modal-body", text: "Hello Alice")
    click_on("Close")

    within("#notification-list") do
      page.accept_confirm { click_on("Remove") }
    end

    expect(page)
      .to have_css("#flash", text: "correspondence has been removed")
    expect(Correspondence.count).to eq(0)
  end
end
