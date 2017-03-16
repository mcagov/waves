def create_submission_from_api!
  data =
    JSON.parse(
      File.read("spec/fixtures/new_registration.json")
    )["data"]["attributes"]

  Submission.create(data)
end

def visit_unassigned_submission
  submission = create(:unassigned_submission)
  login_to_part_3
  visit submission_path(submission)
end

def visit_assigned_submission
  submission = create(:assigned_submission)
  login_to_part_3(submission.claimant)
  visit submission_path(submission)
end

def claim_submission_and_visit
  login_to_part_3
  click_on("Unclaimed Tasks")
  click_on("Claim")
  click_on("Process Next Application")
end

def claim_fee_entry_and_visit
  login_to_part_3
  click_on("Fees Received")
  click_on("Claim")
  click_on("Process Next Application")
end

def visit_assigned_part_1_submission
  submission = create(:assigned_submission, part: :part_1)
  login_to_part_1(submission.claimant)
  visit submission_path(submission)
end

def visit_assigned_part_2_submission
  submission = create(:assigned_submission, part: :part_2)
  login_to_part_2(submission.claimant)
  visit submission_path(submission)
end

def visit_name_approved_part_2_submission
  submission = create(:assigned_submission, part: :part_2)
  create(:submission_name_approval, submission: submission)

  login_to_part_2(submission.claimant)
  visit submission_path(submission)
end

def visit_name_approved_part_1_submission
  submission = create(:assigned_submission, part: :part_1)
  create(:submission_name_approval, submission: submission)

  login_to_part_1(submission.claimant)
  visit submission_path(submission)
end

def visit_name_approved_part_4_submission
  submission = create(:assigned_submission, part: :part_4)
  create(:submission_name_approval, submission: submission)

  login_to_part_4(submission.claimant)
  visit submission_path(submission)
end

def visit_name_approved_part_4_fishing_submission
  submission = create(:part_4_fishing_submission)

  create(:submission_name_approval, submission: submission)

  login_to_part_4(submission.claimant)
  visit submission_path(submission)
end

def visit_part_2_change_vessel_submission
  registered_vessel =
    create(:registered_vessel, part: :part_2, gross_tonnage: 100)
  submission =
    create(:assigned_submission, part: :part_2,
                                 task: :change_vessel,
                                 registered_vessel: registered_vessel)

  login_to_part_2(submission.claimant)
  visit submission_path(submission)
end

def visit_carving_and_marking_ready_submission
  changeset = { vessel_info: { net_tonnage: 1000, name: "CM BOAT" } }
  submission = create(:assigned_submission, part: :part_2, changeset: changeset)

  Builders::OfficialNoBuilder.build(submission)

  login_to_part_2(submission.claimant)
  visit submission_path(submission)
end
