require "rails_helper"

describe "User searches within part 3" do
  before do
    login_to_part_3
  end

  context "for s submission" do
    scenario "searching by part of the submission ref_no" do
      create(:submission, ref_no: "ABC456")
      create(:submission, ref_no: "ABC123")

      within(".nav_menu") { search_for("ABC") }

      within("#searchResults") do
        expect(page).to have_text("Applications (2)")
      end

      within("#submissions") do
        expect(page).to have_css("tr.submission", count: 2)
      end
    end

    scenario "searching by owner postcode" do
      create(:unassigned_submission)

      within(".nav_menu") { search_for("QZ2 3Q") }

      within("#submissions") do
        expect(page).to have_css("tr.submission", count: 1)
      end
    end

    scenario "searching for a submission in another part" do
      create(:fishing_submission, ref_no: "ABC456")

      within(".nav_menu") { search_for("ABC") }

      within("#submissions_tab") do
        expect(page).to have_text("Nothing found")
      end
    end

    scenario "nothing found" do
      within(".nav_menu") { search_for("foo") }

      within("#submissions_tab") do
        expect(page).to have_text("Nothing found")
      end
    end
  end

  context "for a vessel" do
    scenario "searching by part of the vessel reg_no" do
      create(:registered_vessel, reg_no: "MYBOAT")

      within(".nav_menu") { search_for("MYBOAT") }

      within("#searchResults") do
        expect(page).to have_text("Registry (1)")
      end

      within("#vessels") do
        expect(page).to have_css("tr.vessel", count: 1)
      end
    end

    scenario "searching for a vessel in another part" do
      create(:fishing_vessel, reg_no: "MYBOAT")

      within(".nav_menu") { search_for("MYBOAT") }

      within("#vessels_tab") do
        expect(page).to have_text("Nothing found")
      end
    end
  end
end
