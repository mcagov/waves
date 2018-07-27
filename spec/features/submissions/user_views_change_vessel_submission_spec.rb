require "rails_helper"

xfeature "User views change of details submission", type: :feature, js: true do
  let!(:submission) { create(:unassigned_change_vessel_submission) }
  let!(:registered_vessel) { submission.registered_vessel }

  before do
    login_to_part_3
    visit submission_path(submission)
  end

  scenario "rendering vessel, owners and agent tabs" do
    within("h1") do
      expect(page).to have_content(/Change of Vessel details .*ID:/)
    end

    click_link("Vessel Info")
    within("table.submission-vessel") do
      expect(page).to have_css("th", count: 3)

      expect(page)
        .to have_css("td#registry-vessel-name", text: registered_vessel.name)

      expect(page)
        .to have_css("td#vessel-name", text: "No change")
    end

    click_link("Owners")
    expect(page)
      .to have_css("td.owner-name", text: registered_vessel.owners.first.name)

    click_link("Agent")
    within("table#agent") do
      expect(page)
        .to have_css(
          ".registry-agent-name", text: registered_vessel.agent.name)
    end
  end
end
