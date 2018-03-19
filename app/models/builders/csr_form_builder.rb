class Builders::CsrFormBuilder
  class << self
    def build(submission)
      @submission = submission
      @vessel = submission.registered_vessel

      @csr_form = submission.csr_form
      @csr_form ||= build_csr
      @csr_form
    end

    private

    # rubocop:disable all
    def build_csr
      CsrForm.create(
        submission_id: @submission.id,
        vessel_id: @submission.registered_vessel.id,
        issue_number: next_issue_number,
        issued_at: Date.today,
        registered_at: first_registration_date,
        vessel_name: @vessel.name,
        port_name: WavesUtilities::Port.new(@vessel.port_code).name,
        owner_names: listify(@vessel.owners.map(&:name)),
        owner_addresses: listify(@vessel.owners.map(&:inline_address)),
        owner_identification_number: listify(@vessel.owners.map(&:imo_number)),
        charterer_names: listify(@vessel.charter_parties.map(&:name)),
        charterer_addresses:
          listify(@vessel.charter_parties.map(&:inline_address)),
        manager_name: (manager.name if manager),
        manager_address: (manager.inline_address if manager),
        safety_management_address: safety_management_address,
        manager_company_number: listify(@vessel.managers.map(&:imo_number)),
        classification_societies: listify(classification_societies),
        document_of_compliance_issuer: @vessel.doc_issuing_authority,
        document_of_compliance_auditor: @vessel.doc_auditor,
        smc_issuer: @vessel.smc_issuing_authority,
        smc_auditor: @vessel.smc_auditor,
        issc_issuer: @vessel.issc_issuing_authority,
        issc_auditor: @vessel.issc_auditor,
        registration_closed_at: registration_closed_at)
    end
    # rubocop:enable all

    def first_registration_date
      @vessel.first_registration.registered_at if @vessel.first_registration
    end

    def safety_management_address
      if manager && manager.safety_management
        manager.safety_management.inline_address
      end
    end

    def manager
      @manager ||= @vessel.managers.first
    end

    def classification_societies
      [@vessel.classification_society, @vessel.classification_society_other]
    end

    def listify(arr)
      arr.reject(&:blank?).join("; ")
    end

    def next_issue_number
      @submission.registered_vessel.csr_forms.maximum(:issue_number).to_i + 1
    end

    def registration_closed_at
      @vessel.current_registration.closed_at if @vessel.current_registration
    end
  end
end
