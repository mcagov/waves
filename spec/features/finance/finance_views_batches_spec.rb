require "rails_helper"

describe "Finance views batches", type: :feature, js: true do
  before do
    Timecop.travel(Time.new(2016, 6, 18))

    # this week
    @first_batch = create(:finance_batch, opened_at: Time.new(2016, 6, 17))

    # this month
    create(:finance_batch, opened_at: Time.new(2016, 6, 6))

    # this year
    create(:finance_batch, opened_at: Time.new(2016, 1, 6))

    # last year
    create(:finance_batch, opened_at: Time.new(2015, 1, 6))

    login_to_finance
  end

  after do
    Timecop.return
  end

  scenario "viewing scoped lists" do
    click_link("All Batches")
    expect(page).to have_css("h1", text: "Finance: All Batches")
    expect(page).to have_css("tr.batch", count: 4)

    click_link("Batches This Week")
    expect(page).to have_css("h1", text: "Finance: Batches This Week")
    expect(page).to have_css("tr.batch", count: 1)

    click_link("Batches This Month")
    expect(page).to have_css("h1", text: "Finance: Batches This Month")
    expect(page).to have_css("tr.batch", count: 2)

    click_link("Batches This Year")
    expect(page).to have_css("h1", text: "Finance: Batches This Year")
    expect(page).to have_css("tr.batch", count: 3)
  end

  scenario "viewing a batch" do
    click_link("All Batches")
    click_on(@first_batch.batch_no)

    expect(page).to have_current_path(finance_batch_payments_path(@first_batch))
  end
end
