require "rails_helper"

xfeature "User adds documents to a submission", type: :feature, js: true do
  scenario "in general" do
    visit_assigned_submission
    click_on("Documents")
    click_on("Add Document")

    page.attach_file("document_assets_attributes_0_file", mca_file)
    page.attach_file("document_assets_attributes_1_file", mca_file_2)
    fill_in("Notes", with: "Some text")
    fill_in("Date Document Received", with: "01/01/2016")

    click_on("Save Document")
    click_on("Documents")
    within("#documents") do
      expect(page).to have_text("01/01/2016")
      expect(page).to have_text("Some text")
      expect(page).to have_link("mca_test.pdf", href: /mca_test.pdf/)
      expect(page).to have_link("mca_test_2.pdf", href: /mca_test_2.pdf/)
    end

    click_on("History")
    within("#history") do
      expect(page).to have_text("Document entry")
    end
  end
end
