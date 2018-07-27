class Policies::Workflow
  class << self
    def approved_name_required?(submission)
      return false if Policies::Definitions.part_3?(submission)
      return false if submission.registered_vessel
      return false if submission.name_approval.try(:persisted?)
      true
    end

    def generate_official_no?(submission, user)
      return false if Policies::Definitions.part_3?(submission)

      submission.actionable? &&
        submission.claimant == user &&
        !approved_name_required?(submission)
    end

    def can_edit_official_number?(user)
      user.team_leader? || user.system_manager?
    end

    def can_unclaim_team_tasks?(user)
      user.team_leader? || user.system_manager?
    end

    def uses_port_no?(obj)
      Policies::Definitions.fishing_vessel?(obj)
    end

    def uses_csr_forms?(obj)
      return false if Policies::Definitions.fishing_vessel?(obj)
      return false if Policies::Definitions.part_3?(obj)
      true
    end

    def uses_extended_engines?(obj)
      Policies::Definitions.fishing_vessel?(obj)
    end

    def uses_extended_owners?(obj)
      Policies::Definitions.fishing_vessel?(obj)
    end

    def uses_shareholding?(obj)
      [:part_1, :part_2].include?(obj.part.to_sym)
    end

    def uses_managing_owner?(obj)
      [:part_1, :part_2].include?(obj.part.to_sym)
    end

    def uses_editable_registration_type?(obj)
      Policies::Definitions.part_2?(obj)
    end

    def uses_vessel_attribute?(attr, obj)
      @part = obj.part.to_sym

      WavesUtilities::Vessel.attributes_for(
        @part, Policies::Definitions.fishing_vessel?(obj)
      ).include?(attr.to_sym)
    end

    def uses_certificates_and_documents?(submission)
      DeprecableTask.new(submission.task).builds_registry?
    end

    def uses_registration_types?(part)
      part != :part_3
    end
  end
end
