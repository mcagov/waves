class Submission::ApplicationProcessor
  class << self
    def run(submission, approval_params)
      @submission = submission
      @task = DeprecableTask.new(@submission.task)
      @approval_params = approval_params

      assign_registered_vessel
      assign_registration

      build_print_jobs
    end

    private

    def assign_registered_vessel
      @registered_vessel =
        if @task.builds_registry?
          Builders::RegistryBuilder.create(@submission, @approval_params)
        else
          @submission.registered_vessel
        end
    end

    def assign_registration
      if @task.builds_registration?
        build_new_registration
      elsif @task == :closure
        build_closed_registration
      elsif @task.mortgages?
        build_mortgage_registration
      else
        build_cloned_registration
      end
    end

    def build_new_registration
      Builders::RegistrationBuilder
        .create(
          @submission,
          @registered_vessel,
          @approval_params[:registration_starts_at],
          @approval_params[:registration_ends_at])
    end

    def build_mortgage_registration
      Builders::RegistrationBuilder
        .create(
          @submission,
          @registered_vessel,
          @registered_vessel.registered_at,
          @registered_vessel.registered_until)
    end

    def build_closed_registration
      Builders::ClosedRegistrationBuilder
        .create(
          @submission,
          @approval_params[:closure_at],
          @approval_params[:closure_reason],
          @approval_params[:supporting_info])
    end

    def build_cloned_registration
      Builders::ClonedRegistrationBuilder.create(@submission)
    end

    def build_print_jobs
      return if !@task.print_job_templates || @submission.electronic_delivery?

      Builders::PrintJobBuilder
        .create(
          @submission,
          printable,
          @submission.part,
          @task.print_job_templates)
    end

    def printable
      @task.issues_csr? ? @submission.csr_form : @submission.registration
    end
  end
end
