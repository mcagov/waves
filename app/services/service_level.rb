class ServiceLevel
  SERVICE_LEVEL_TYPES = [
    ["Standard", :standard],
    ["Premium", :premium],
  ].freeze

  class << self
    def available_types(service, part)
      if service.supports_premium?(part)
        SERVICE_LEVEL_TYPES
      else
        [SERVICE_LEVEL_TYPES.first]
      end
    end
  end
end
