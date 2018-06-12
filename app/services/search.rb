class Search
  class << self
    def submissions(term, part = nil)
      submissions = PgSearch.multisearch(term)
                            .where(searchable_type: "Submission")
                            .includes(:searchable)
      submissions = submissions_in_part(submissions, part)
      submissions.limit(20).map(&:searchable)
    end

    def vessels(term, part = nil)
      vessels = PgSearch.multisearch(term)
                        .where(searchable_type: "Register::Vessel")
                        .includes(:searchable)
      vessels = vessels_in_part(vessels, part)
      vessels.limit(20).map(&:searchable)
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

    private

    def vessels_in_part(arel, part)
      return arel unless part

      arel.joins("LEFT JOIN vessels ON (vessels.id =
                 pg_search_documents.searchable_id)"
                ).where("vessels.part = ?", part)
    end

    def submissions_in_part(arel, part)
      return arel unless part

      arel.joins("LEFT JOIN submissions ON (submissions.id =
                 pg_search_documents.searchable_id)"
                ).where("submissions.part = ?", part)
    end
  end
end
