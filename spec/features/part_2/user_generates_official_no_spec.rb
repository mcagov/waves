require "rails_helper"

describe "User generates an official no", js: true do
  before do
    # with a submission that has a name approval
    visit_claimed_task(
      submission: create(:name_approval).submission)

    within("#heading .official-no") do
      click_on("Generate")
    end
  end

  scenario "with a system-generated no" do
    within(".modal.fade.in") do
      click_on("Continue")
    end

    within("#heading") do
      vessel = Register::Vessel.last
      expect(page).to have_css(".official-no", text: vessel.reg_no)
      expect(page).to have_css("#ec-no", text: vessel.ec_no)
    end
  end

  scenario "with valid user-input" do
    within(".modal.fade.in") do
      find_field("official_no_content").set("VESSEL_REG_NO")
      click_on("Continue")
    end

    within("#heading") do
      expect(page).to have_css(".official-no", text: "VESSEL_REG_NO")
      expect(page).to have_css("#ec-no", text: "GBR000VESSEL_REG_NO")
    end
  end

  scenario "with invalid user-input" do
    create(:registered_vessel, part: @submission.part, reg_no: "SSR200001")

    within(".modal.fade.in") do
      find_field("official_no_content").set("SSR200001")
      click_on("Continue")
    end

    expect(page).to have_css(".modal.fade.in", text: "Generate Official No")
  end
end
