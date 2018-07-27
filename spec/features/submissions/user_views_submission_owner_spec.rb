require "rails_helper"

xfeature "User views owner submission details", type: :feature, js: true do
  let!(:submission) { create(:unassigned_change_vessel_submission) }
  let!(:registered_vessel) { submission.registered_vessel }
  let!(:registered_owner) { registered_vessel.owners.first }
  let!(:declaration) { submission.declarations.first }

  before do
    declaration.owner.name = "NEW OWNER NAME"
    declaration.save!

    login_to_part_3
    visit submission_path(submission)
  end

  scenario "displaying the submission and registry owner lists" do
    owner = declaration.owner

    click_on("Owners")
    expect(page).to have_css(".owner-name", text: "NEW OWNER NAME")
    expect(page).to have_css(".owner-email", text: owner.email)
    expect(page).to have_css(".owner-phone_number", text: owner.phone_number)
    expect(page).to have_css(".owner-nationality", text: owner.nationality)
    expect(page).to have_css(".declaration-status", text: "n/a")

    expect(page).to have_css(".strike", text: registered_owner.name)
    expect(page).to have_css(".strike", text: registered_owner.email)
    expect(page).to have_css(".strike", text: registered_owner.nationality)
    expect(page).to have_css(".strike", text: registered_owner.inline_address)
  end
end
