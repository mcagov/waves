FactoryBot.define do
  factory :service do
    standard_days 10
    premium_days 3

    trait :carving_and_marking_required do
      rules { [:carving_and_marking_required] }
    end

    trait :declarations_required do
      rules { [:declarations_required] }
    end

    trait :duplicate_registration_certificate do
      print_templates { [:duplicate_registration_certificate] }
    end

    trait :generate_new_5_year_registration do
      activities { [:generate_new_5_year_registration] }
    end

    trait :generate_provisional_registration do
      activities { [:generate_provisional_registration] }
    end

    trait :issues_csr do
      rules { [:issues_csr] }
      activities { [:issue_csr] }
    end

    trait :prints_csr_form do
      print_templates { [:csr_form] }
    end

    trait :restore_closure do
      activities { [:restore_closure] }
    end

    trait :registered_vessel_required do
      rules { [:registered_vessel_required] }
    end

    trait :registry_not_editable do
      rules { [:registry_not_editable] }
    end

    trait :update_registry_details do
      activities { [:update_registry_details] }
    end

    trait :validates_on_approval do
      rules { [:validates_on_approval] }
    end
  end

  factory :demo_service, parent: :service do
    name "Demo Service"
    standard_days 10
    premium_days 1
    part_1 { { standard: 124, premium: 180, subsequent: 99 } }
    part_3 { { standard: 25, premium: 50 } }
    part_4 { { standard: 124, premium: 180 } }
  end

  factory :subsequent_only_service, parent: :service do
    name "Subsequent Service"
    standard_days 10
    part_3 { { subsequent: 15 } }
  end

  factory :standard_only_service, parent: :service do
    standard_days 10
    part_3 { { standard: 99 } }
  end
end
