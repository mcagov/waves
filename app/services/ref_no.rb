class RefNo
  class << self
    def generate(prefix)
      build_unique(prefix)
    end

    private

    def build_unique(prefix)
      ref_no = prefix + "-" + SecureRandom.hex(3)
      if Submission.where(ref_no: ref_no).empty?
        ref_no
      else
        build_unique
      end
    end
  end
end
