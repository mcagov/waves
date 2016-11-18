class Task
  def initialize(key)
    @key = key.to_sym
  end

  def description
    Task.all_task_types.find { |t| t[1] == @key }[0]
  end

  def payment_required?
    ![:change_address, :closure].include?(@key)
  end

  def prints_certificate?
    [
      :new_registration, :change_owner, :change_vessel, :renewal,
      :duplicate_certificate, :re_registration
    ].include?(@key)
  end

  def duplicates_certificate?
    [:duplicate_certificate].include?(@key)
  end

  def renews_certificate?
    [:change_owner, :change_vessel, :renewal, :re_registration]
      .include?(@key)
  end

  def builds_registry?
    [
      :change_owner, :change_vessel, :change_address,
      :re_registration, :new_registration, :renewal].include?(@key)
  end

  class << self
    def finance_task_types
      all_task_types.delete_if do |t|
        [:change_address, :closure, :enquiry].include?(t[1])
      end
    end

    def default_task_types
      all_task_types.delete_if { |t| t[1] == :unknown }
    end

    def validation_helper_task_type_list
      default_task_types.map { |t| t[1].to_s }
    end

    # rubocop:disable Metrics/MethodLength
    def all_task_types
      [
        ["New Registration", :new_registration],
        ["Renewal of Registration", :renewal],
        ["Re-Registration", :re_registration],
        ["Change of Ownership", :change_owner],
        ["Change of Vessel details", :change_vessel],
        ["Change of Address", :change_address],
        ["Registration Closure", :closure],
        ["Transcript of Registry (current, closed, historic, dated)",
         :transcript],
        ["Duplicate Certificate", :duplicate_certificate],
        ["General Enquiry", :enquiry],
        ["Unknown", :unknown]]
    end
  end
end
