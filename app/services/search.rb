class Search
  class << self
    def submissions(term, part = nil)
      term = RefNo.parse(term)
      submissions = PgSearch.multisearch(term)
                            .where(searchable_type: "Submission")
                            .includes(searchable: [declarations: :owner])
      submissions = submissions_in_part(submissions, part)
      submissions.limit(50).map(&:searchable)
    end

    def vessels(term, part = nil)
      vessels = PgSearch.multisearch(term)
                        .where(searchable_type: "Register::Vessel")
                        .includes(searchable: [:owners, :submissions])
      vessels = vessels_in_part(vessels, part)
      vessels.limit(50).map(&:searchable)
    end

    def finance_payments(term)
      PgSearch.multisearch(term)
              .where(searchable_type: "Payment::FinancePayment")
              .includes(:searchable)
              .limit(100)
              .map(&:searchable)
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
