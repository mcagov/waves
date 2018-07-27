require "rails_helper"

xdescribe "User edits mortgages", js: :true do
  scenario "adding, editing and removing" do
    visit_name_approved_part_1_submission
    click_on("Mortgages")
    click_on("Add Mortgage")

    within(".modal.fade.in") do
      select("A", from: "Priority Code")
      select("Intent", from: "Mortgage Type")
      fill_in("Reference Number", with: "REF 1")
      fill_in("Date Executed", with: "01/02/2001")
      select("12", from: "Shares Mortgaged")

      fill_in("Name of Mortgagor", with: "Bob")
      click_on("Add Extra Mortgagor")
      within all("#mortgagors .nested-fields")[1] do
        fill_in("Name of Mortgagor", with: "Mary")
        click_on("Remove")
      end

      fill_in("Name of Mortgagee", with: "Alice")
      click_on("Add Extra Mortgagee")
      within all("#mortgagees .nested-fields")[1] do
        fill_in("Name of Mortgagee", with: "Charlie")
        click_on("Remove")
      end

      click_on("Add Mortgage")
    end

    within("#mortgages_tab") do
      expect(page).to have_css(".priority", text: "A")
      expect(page).to have_css(".mortgage_type", text: "Intent")
      expect(page).to have_css(".reference_number", text: "REF 1")
      expect(page).to have_css(".executed_at", text: "Thu Feb 01, 2001")
      expect(page).to have_css(".amount", text: "12")
      expect(page).to have_css(".mortgagors", text: "BOB")
      expect(page).to have_css(".mortgagees", text: "ALICE")

      click_on("Intent")
    end

    within(".modal.fade.in") do
      expect(find_field("Priority Code").value).to eq("A")
      fill_in("Reference Number", with: "REF 2")
      fill_in("Date Discharged", with: "02/02/2012")
      click_on("Save Mortgage")
    end

    within("#mortgages_tab") do
      expect(page).to have_css("tr.strike .reference_number", text: "REF 2")
    end

    within("#mortgages_tab") do
      click_on("Remove")
      expect(page).not_to have_css(".reference_number")
      expect(Submission.last.mortgages).to be_empty
    end
  end
end
