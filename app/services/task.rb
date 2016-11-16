class Task
  def initialize(key)
    @key = key.to_sym
  end

  def description
    Task.task_types.find { |t| t[1] == @key }[0]
  end

  def payment_required?
    ![:change_address, :closure].include?(@key)
  end

  def prints_certificate?
    [
      :new_registration, :change_registry_details, :renewal,
      :duplicate_certificate
    ].include?(@key)
  end

  def duplicates_certificate?
    [:duplicate_certificate].include?(@key)
  end

  def renews_certificate?
    [:change_registry_details, :renewal]
      .include?(@key)
  end

  def builds_registry?
    [
      :change_registry_details, :change_address,
      :new_registration, :renewal].include?(@key)
  end

  class << self
    def receipt_entry_task_types
      [
        ["Duplicate Certificate of Registry", :duplicate_certificate],
        ["Change of Ownership", :change_owner],
        ["Change of Vessel Details", :change_details],
        ["Name Reservation", :reserve_name],
        ["New Registration", :new_registration],
        ["Registration Renewal", :renewal],
        ["Transcript Request", :transcript],
        ["Unkown", :unknown]]
    end

    def task_types
      [
        ["Change of Registry Details", :change_registry_details],
        ["Change of Address", :change_address],
        ["Duplicate Certificate of Registry", :duplicate_certificate],
        ["Name Reservation", :reserve_name],
        ["New Registration", :new_registration],
        ["Registration Renewal", :renewal],
        ["Registration Closure", :closure],
        ["Transcript Request", :transcript]]
    end

    def validation_helper_task_type_list
      task_types.map { |t| t[1].to_s }
    end
  end
end
