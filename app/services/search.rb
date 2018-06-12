class Search
  class << self
    def submissions(term, part = nil)
      Submission.in_part(part).limit(20).scoped_search(term)
    end

    # looks up a vessel to help user complete
    # a finance payment or document entry form
    def vessels(term, part = nil)
      vessels = PgSearch.multisearch(term)
                        .where(searchable_type: "Register::Vessel")
                        .limit(20)
                        .includes(:searchable)
                        .map(&:searchable)
      # temporary #in_part implementation
      if part
        vessels.select { |vessel| vessel.part.to_sym == part }
      else
        vessels
      end
    end

    # looks for submissions for the same vessel
    # to help a reg officer on the convert application
    # page
    def similar_submissions(submission)
      return [] unless submission.registered_vessel
      submission.registered_vessel.submissions.active.where.not(ref_no: nil)
    end

    # looks for similar vessels, to help
    # a reg officer on a part_3 application page
    def similar_vessels(part, vessel) # rubocop:disable Metrics/MethodLength
      Register::Vessel
        .in_part(part)
        .where(name: vessel.name)
        .or(Register::Vessel
          .where(["hin = ? and hin <> ''", vessel.hin]))
        .or(Register::Vessel
            .where(["mmsi_number = ? and mmsi_number <> ''",
                    vessel.mmsi_number]))
        .or(Register::Vessel
          .where(["radio_call_sign = ? and radio_call_sign <> ''",
                  vessel.radio_call_sign]))
    end
  end
end
