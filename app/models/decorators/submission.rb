class Decorators::Submission < SimpleDelegator
  def initialize(submission)
    @submission = submission
    super
  end

  def similar_vessels
    Search.similar_vessels(part, vessel)
  end

  def source_description
    source.titleize if source
  end

  def registered_agent
    @registered_agent ||= registered_vessel.try(:agent) || Register::Agent.new
  end

  def registered_owners
    @registered_owners ||= registered_vessel.try(:owners) || []
  end

  def removed_registered_owners
    declaration_owner_names =
      declarations.map { |declaration| declaration.owner.name.upcase }

    registered_owners.select do |registered_owner|
      !declaration_owner_names.include?(registered_owner.name)
    end
  end

  def payment_status
    AccountLedger.new(@submission).payment_status
  end

  def declaration_status
    Policies::Declarations.new(@submission).declaration_status
  end

  def changed_vessel_attribute(attr_name)
    return unless registered_vessel

    registered_version = registered_vessel.send(attr_name).to_s.strip
    changeset_version = @submission.vessel.send(attr_name).to_s.strip

    return if registered_version == changeset_version
    registered_version
  end

  def delivery_description
    delivery_address.inline_name_and_address
  end

  def radio_call_sign
    vessel.radio_call_sign if vessel
  end

  def mmsi_number
    vessel.mmsi_number if vessel
  end

  def registration_type
    vessel.registration_type if vessel
  end

  def can_issue_carving_and_marking?
    vessel_reg_no
  end

  def delivery_address_description
    return "Not set" unless delivery_address.active?
    delivery_address.name_and_address.join("<br/>").html_safe
  end

  def advisories
    @advisories ||= Policies::Advisories.for_submission(self)
  end

  def outstanding_carving_and_marking?
    !carving_and_markings.empty? &&
      carving_and_marking_received_at.blank? &&
      carving_and_marking_receipt_skipped_at.present?
  end
end
