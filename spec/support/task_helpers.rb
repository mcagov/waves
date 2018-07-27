def visit_claimed_task
  submission = create(:submission)
  create(:payment, submission: submission)
  task = create(:claimed_submission_task, submission: submission)
  login_to_part_3(task.claimant)
  visit submission_path(task.submission)
end
