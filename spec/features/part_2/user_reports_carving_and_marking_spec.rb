require "rails_helper"

describe "User reports receipt of a Carving & Marking note", js: true do
  scenario "in general" do
    visit_carving_and_marking_ready_submission
    click_on("Certificates & Documents")

    within("#carving_and_marking .status") do
      click_on("Mark as Received")
    end

    within("#carving_and_marking .status") do
      click_on("Mark as Pending")
    end
  end
end
