class Builders::ClosedRegistrationBuilder
  class << self
    def create(submission, closure_at, closure_reason)
      @submission = submission
      @closure_at = closure_at
      @closure_reason = closure_reason
      @registered_vessel = @submission.registered_vessel
      @previous_registration = @registered_vessel.current_registration

      create_closed_registration
    end

    private

    def create_closed_registration
      Registration.create(
        vessel_id: @registered_vessel.id,
        registered_at: @previous_registration.try(:registered_at),
        registered_until: @previous_registration.try(:registered_until),
        closed_at: @closure_at,
        description: @closure_reason,
        submission_ref_no: @submission.ref_no,
        task: @submission.task,
        registry_info: @registered_vessel.registry_info,
        actioned_by: @submission.claimant)
    end
  end
end