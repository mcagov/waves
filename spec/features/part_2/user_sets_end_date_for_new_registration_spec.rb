require "rails_helper"

xdescribe "User sets end date for new registration", js: :true do
  scenario "in general" do
    visit_name_approved_part_2_submission

    click_on("Save Details")
    click_on("Complete Registration")

    expect(find_field("Registration Expiry Date").value.to_date)
      .to eq(Time.zone.today.advance(years: 5))
    fill_in("Registration Expiry Date", with: "13/12/2030")
    click_on("Register Vessel")

    expect(page).to have_text("registered on Part II of the UK Ship Register")
    expect(Registration.last.registered_until.to_date)
      .to eq("13/12/2030".to_date)
  end
end
