class Decorators::Submission < SimpleDelegator
  def initialize(submission)
    @submission = submission
    super
  end

  def similar_vessels
    Search.similar_vessels(part, vessel)
  end

  def notification_list
    Builders::NotificationListBuilder.for_submission(@submission)
  end

  def source_description
    source.titleize if source
  end

  def display_registry_info?
    return false if DeprecableTask.new(task).re_registration?
    registered_vessel
  end

  def display_changeset?
    DeprecableTask.new(task).builds_registry?
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

  def payment_received
    AccountLedger.new(@submission).amount_paid
  end

  def declaration_status
    Policies::Declarations.new(@submission).declaration_status
  end

  def vessel_can_be_edited?
    DeprecableTask.new(task).vessel_can_be_edited?
  end

  def ownership_can_be_changed?
    DeprecableTask.new(task).ownership_can_be_changed?
  end

  def address_can_be_changed?
    DeprecableTask.new(task).address_can_be_changed?
  end

  def new_registration?
    DeprecableTask.new(task).new_registration?
  end

  def changed_vessel_attribute(attr_name)
    return if new_registration? || !registered_vessel

    registered_version = registered_vessel.send(attr_name).to_s.strip
    changeset_version = @submission.vessel.send(attr_name).to_s.strip

    return if registered_version == changeset_version
    registered_version
  end

  def delivery_description
    if electronic_delivery?
      "Electronic delivery"
    elsif delivery_address.active?
      delivery_address.inline_name_and_address
    end
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

  def referrable?
    DeprecableTask.new(task).referrable?
  end

  def applicant_description
    return "Not set" unless applicant_name.present?
    description = applicant_name
    description =
      "#{description} (#{applicant_email})" if applicant_email.present?
    description
  end

  def delivery_address_description
    return "Not set" unless delivery_address.active?
    delivery_address.name_and_address.join("<br/>").html_safe
  end

  def advisories
    @advisories ||= Policies::Advisories.for_submission(self)
  end
end
