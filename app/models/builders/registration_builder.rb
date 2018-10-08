class Builders::RegistrationBuilder
  class << self
    def create(task, registered_vessel, starts_at, ends_at, provisional)
      registration = Registration.create(
        vessel_id: registered_vessel.id,
        registered_at: registered_at(task, starts_at),
        registered_until: registered_until(task, ends_at),
        registry_info: registered_vessel.registry_info,
        actioned_by: task.claimant,
        provisional: provisional)

      task.submission.update_attributes(registration: registration)
      registered_vessel.update_attributes(current_registration: registration)

      registration
    end

    private

    def registered_at(task, input)
      input.blank? ? RegistrationDate.for(task).starts_at : input
    end

    def registered_until(task, input)
      input.blank? ? RegistrationDate.for(task).ends_at : input
    end
  end
end
