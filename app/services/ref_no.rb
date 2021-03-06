class RefNo
  class << self
    def generate
      build_unique
    end

    def parse(input)
      input.gsub(%r{\/[0-9]*}, "") if input
    end

    private

    def build_unique
      ref_no = SecureRandom.hex(3).upcase
      if Submission.where(ref_no: ref_no).empty?
        ref_no
      else
        build_unique
      end
    end
  end
end
