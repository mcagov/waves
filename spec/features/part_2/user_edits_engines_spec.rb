require "rails_helper"

xdescribe "User edits engines", js: :true do
  scenario "in general" do
    visit_name_approved_part_2_submission
    click_on("Engines")
    click_on("Add Engine(s)")

    within(".modal.fade.in") do
      select("Outboard", from: "Engine Type")
      fill_in("Engine Make", with: "Honda")
      fill_in("Engine Model", with: "XT600")
      fill_in("Cylinders", with: "4")
      fill_in("MCEP per Engine", with: 100.34)
      select("Turbo Charger Removed", from: "Derating")
      fill_in("RPM", with: "1200")
      fill_in("MCEP after Derating", with: "300.1")
      fill_in("Quantity", with: "6")

      click_on("Add Engine")
    end

    within("#engines") do
      expect(page).to have_css(".make_and_model", text: "HONDA XT600")
      expect(page).to have_css(".cylinders", text: "4")
      expect(page).to have_css(".mcep_per_engine", text: "100.34kW")
      expect(page).to have_css(".derating", text: "Turbo Charger Removed")
      expect(page).to have_css(".rpm", text: "1200")
      expect(page).to have_css(".mcep_after_derating", text: "300.1kW")
      expect(page).to have_css(".quantity", text: "6")
      expect(page).to have_css(".total_mcep", text: "Total MCEP: 1800.6kW")

      click_on("Outboard")
    end

    within(".modal.fade.in") do
      select("Outboard", from: "Engine Type")
      fill_in("Engine Make", with: "Yamaha")
      click_on("Save Engine")
    end

    within("#engines") do
      expect(page).to have_css(".make_and_model", text: "YAMAHA XT600")
    end

    within("#engines") do
      click_on("Remove")
      expect(page).not_to have_css(".make_and_model")
      expect(Submission.last.engines).to be_empty
    end
  end
end
