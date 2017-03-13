class Policies::Definitions
  class << self
    def fishing_vessel?(obj)
      @part = obj.part.to_sym
      return true if @part == :part_2
      return true if @part == :part_4 && registration_type(obj) == :fishing
      false
    end

    def registration_type(obj)
      if obj.is_a?(Register::Vessel)
        obj.registration_type
      elsif obj.is_a?(Submission)
        submission.registered_vessel.registration_type
      end
    end

    def mortgageable?(obj)
      @part = obj.part.to_sym
      return true if @part == :part_1
      return true if @part == :part_2 && registration_type(obj) == :full
      false
    end
  end
end
