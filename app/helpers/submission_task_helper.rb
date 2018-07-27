module SubmissionTaskHelper
  def link_to_create_task(service, price, service_level)
    return "n/a" unless price

    submission_task = Submission::Task.new(
      service: service,
      submission: @submission,
      service_level: service_level,
      price: price)

    render partial: "/submission/tasks/new",
           locals: { submission_task: submission_task }
  end
end
