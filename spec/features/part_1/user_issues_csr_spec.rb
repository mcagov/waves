require "rails_helper"

xdescribe "User issues CSR", js: true do
  scenario "in general" do
    visit_assigned_csr_submission

    expect(find("#csr_form_issue_number").value).to eq("1")
    expect(find("#csr_form_vessel_name").value).to match(/Registered Boat.*/)
    find("#csr_form_remarks").set("NO COMMENT")
    click_on("Save Details")

    expect(page)
      .to have_link("Go to Task List", href: tasks_my_tasks_path)

    expect(Submission.last.csr_form.remarks).to eq("NO COMMENT")

    click_on("Issue CSR")
    click_on("Approve & Issue CSR")

    pdf_window = window_opened_by do
      click_on("Print CSR")
    end

    within_window(pdf_window) do
      expect(page).to have_text("%PDF")
    end

    visit "/print_queue/csr_form"
    expect(page).to have_link("Re-Print")
  end
end
