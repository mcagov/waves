require "rails_helper"

feature "User logs in", type: :feature, js: true do
  before do
    visit root_path
  end

  context "using email/password" do
    let!(:password) { "Abc123456!" }
    let!(:user) { create(:user, password: password, name: "Bob") }

    scenario "user is taken to the dashboard with correct info" do
      perform_sign_in user.email, password

      expect(page).to_not have_content("Login")
      expect(page).to have_text(successfully_loggedin_page)

      # logging out
      click_on("Part 3")
      find(".dropdown-toggle").click
      find("#logout").click

      expect_login_page
    end

    scenario "user is not taken to the dashboard with incorrect info" do
      perform_sign_in user.email, "wrong_password"

      expect_login_page
    end

    scenario "user can't login when the account is disabled" do
      user.update_attributes(disabled: true)
      perform_sign_in user.email, password

      expect_login_page
    end
  end

  scenario "visiting when not logged in" do
    visit tasks_unclaimed_path

    expect_login_page
  end

  def perform_sign_in(email, password)
    fill_in "Email address", with: email
    fill_in "Password", with: password

    click_on "Login"
  end

  def successfully_loggedin_page
    "Select Register"
  end

  def expect_login_page
    expect(page).to have_css("h1", text: "Login to Waves")
    expect(page).to_not have_content(successfully_loggedin_page)
  end
end
