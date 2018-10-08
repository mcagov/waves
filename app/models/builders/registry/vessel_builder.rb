class Builders::Registry::VesselBuilder
  class << self
    def create(submission, approval_params)
      @submission = submission
      @approval_params = approval_params

      perform

      @vessel.reload
    end

    private

    def perform
      @vessel = @submission.registered_vessel
      @vessel ||= Register::Vessel.new(part: @submission.part)

      build_summary
      build_identity
      build_operational_info
      build_description
      build_construction

      @vessel.save
    end

    def build_summary
      @vessel.name = @submission.vessel.name
      @vessel.hin = @submission.vessel.hin
      @vessel.make_and_model = @submission.vessel.make_and_model
      @vessel.length_in_meters = @submission.vessel.length_in_meters
      @vessel.number_of_hulls = @submission.vessel.number_of_hulls
      @vessel.mmsi_number = @submission.vessel.mmsi_number
      @vessel.radio_call_sign = @submission.vessel.radio_call_sign
      @vessel.vessel_type = @submission.vessel.type_of_vessel
      @vessel.autonomous_vessel = @submission.vessel.autonomous_vessel
    end

    # rubocop:disable all
    def build_identity # # extended#Identity section
      @vessel.registration_type = @submission.vessel.registration_type
      @vessel.vessel_category = @submission.vessel.vessel_category
      @vessel.imo_number = @submission.vessel.imo_number
      @vessel.port_code = @submission.vessel.port_code
      @vessel.port_no = @submission.vessel.port_no
      @vessel.last_registry_country = @submission.vessel.last_registry_country
      @vessel.last_registry_no = @submission.vessel.last_registry_no
      @vessel.last_registry_port = @submission.vessel.last_registry_port
      @vessel.underlying_registry = @submission.vessel.underlying_registry
      @vessel.underlying_registry_identity_no = @submission.vessel.underlying_registry_identity_no
      @vessel.underlying_registry_port = @submission.vessel.underlying_registry_port
      @vessel.name_on_primary_register = @submission.vessel.name_on_primary_register
    end

    def build_operational_info # extended#Operational Information section
      @vessel.classification_society = @submission.vessel.classification_society
      @vessel.classification_society_other =
        @submission.vessel.classification_society_other
      @vessel.entry_into_service_at = entry_into_service_at
      @vessel.area_of_operation = @submission.vessel.area_of_operation
      @vessel.alternative_activity = @submission.vessel.alternative_activity
      @vessel.smc_issuing_authority = @submission.vessel.smc_issuing_authority
      @vessel.smc_auditor = @submission.vessel.smc_auditor
      @vessel.issc_issuing_authority = @submission.vessel.issc_issuing_authority
      @vessel.issc_auditor = @submission.vessel.issc_auditor
      @vessel.doc_issuing_authority = @submission.vessel.doc_issuing_authority
      @vessel.doc_auditor = @submission.vessel.doc_auditor
    end
    # rubocop:enable all

    def build_description # extended#Description section
      @vessel.gross_tonnage = @submission.vessel.gross_tonnage
      @vessel.net_tonnage = @submission.vessel.net_tonnage
      @vessel.register_tonnage = @submission.vessel.register_tonnage
      @vessel.register_length = @submission.vessel.register_length
      @vessel.length_overall = @submission.vessel.length_overall
      @vessel.breadth = @submission.vessel.breadth
      @vessel.depth = @submission.vessel.depth
      @vessel.propulsion_system = @submission.vessel.propulsion_system
    end

    def build_construction # extended#Construction section
      @vessel.name_of_builder = @submission.vessel.name_of_builder
      @vessel.builders_address = @submission.vessel.builders_address
      @vessel.place_of_build = @submission.vessel.place_of_build
      @vessel.country_of_build = @submission.vessel.country_of_build
      @vessel.keel_laying_date = @submission.vessel.keel_laying_date
      @vessel.hull_construction_material =
        @submission.vessel.hull_construction_material
      @vessel.year_of_build = @submission.vessel.year_of_build
    end

    def entry_into_service_at
      if @submission.vessel.entry_into_service_at.present?
        @submission.vessel.entry_into_service_at
      else
        @approval_params[:registration_starts_at]
      end
    end
  end
end
