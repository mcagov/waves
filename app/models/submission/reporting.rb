module Submission::Reporting
  class << self
    # rubocop:disable all
    def included(base)
      # this association should only be used for reporting
      # ordinarily we scope a submission's registered_vessel
      # to the registry part
      base.belongs_to :reportable_registered_vessel,
          class_name: "Register::Vessel",
          foreign_key: :registered_vessel_id

      base.scope :flag_in, -> do
        where(application_type: DeprecableTask.flag_in)
      end

      base.scope :flag_out, -> do
        where(application_type:  DeprecableTask.flag_out)
      end

      base.scope :merchant_vessels, (lambda do
        where(
          "(part = 'part_1') OR "\
          "(part = 'part_4' AND "\
          "changeset#>>'{vessel_info, registration_type}' != 'fishing')")
      end)

      base.scope :fishing_vessels, (lambda do
        where(
          "(part = 'part_2') OR "\
          "(part = 'part_4' AND "\
          "changeset#>>'{vessel_info, registration_type}' = 'fishing')")
      end)

      base.scope :under_15m, (lambda do
        where(
          "cast
            (coalesce(nullif(
              (changeset#>>'{vessel_info, register_length}'), ''), '0')
                as numeric) < 15.0")
      end)

      base.scope :between_15m_24m, (lambda do
        where(
          "cast
            (coalesce(nullif(
              (changeset#>>'{vessel_info, register_length}'), ''), '0')
                as numeric) between 15.0 and 24.0")
      end)

      base.scope :over_24m, (lambda do
        where(
          "cast
            (coalesce(nullif(
              (changeset#>>'{vessel_info, register_length}'), ''), '0')
                as numeric) > 24.0")
      end)

      base.scope :commercial, (lambda do
        where(
          "(part = 'part_1') AND "\
          "(changeset#>>'{vessel_info, registration_type}' = 'commercial')"
          )
      end)

      base.scope :over_100gt, (lambda do
        where(
          "cast
            (coalesce(nullif(
              (changeset#>>'{vessel_info, gross_tonnage}'), ''), '0')
                as numeric) > 100.0")
      end)
    end
    # rubocop:enable all
  end
end
