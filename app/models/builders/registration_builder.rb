class Builders::RegistrationBuilder
  class << self
    def create(submission, registered_vessel, starts_at, ends_at = nil)
      @submission = submission
      @registered_vessel = registered_vessel
      @starts_at = starts_at || Time.zone.today
      @ends_at = ends_at || default_end_date
      perform
    end

    private

    def perform
      registration = Registration.create(
        vessel_id: @registered_vessel.id,
        registered_at: @starts_at,
        registered_until: @ends_at,
        registry_info: @registered_vessel.registry_info,
        actioned_by: @submission.claimant,
        provisional:
          DeprecableTask.new(@submission.task).provisional_registration?)

      @submission.update_attributes(registration: registration)

      registration
    end

    def default_end_date
      RegistrationDate.for(@submission, @starts_at).ends_at
    end
  end
end
