require "rails_helper"

xfeature "User views submission for similar vessel", type: :feature, js: true do
  scenario "viewing a vessel with similar name and different mmsi_number" do
    create(:registered_vessel, mmsi_number: 233878594)
    create(:registered_vessel, name: "CELEBRATOR DOPPELBOCK")

    login_to_part_3
    visit submission_path(create_submission_from_api!)

    # submitted vessel information
    within("td#vessel-name") do
      expect(page).to have_css(".i.fa.fa-star-o")
    end

    # similar vesels pane
    within("#similar-vessels") do
      expect(page).to have_text("Similar Vessels")

      within(".vessel-name", text: "CELEBRATOR DOPPELBOCK") do
        expect(page).to have_css(".i.fa.fa-star-o")
        click_link("CELEBRATOR DOPPELBOCK")
      end
    end

    expect(page).to have_css("h1", text: "CELEBRATOR DOPPELBOCK")
  end

  scenario "no similar vessels" do
    visit_assigned_submission
    expect(page).not_to have_css("#similar-vessels")
  end
end
