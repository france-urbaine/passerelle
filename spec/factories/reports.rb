# frozen_string_literal: true

FactoryBot.define do
  factory :report do
    # We first build a report without collectivity,
    # we'll assign it in an after(:build) callback to ensure conformity.
    #
    #   build(:report)
    #     - No collectivity assigned to the report
    #     - A new collectivity is assigned to the package
    #     - The package collectivity is assigned to the report after build
    #
    #   build(:report, package: one_package)
    #     - No collectivity assigned to the report
    #     - The package should already have a collectivity
    #     - The package collectivity is assigned to the report after build
    #
    #   build(:report, collectivity: one_collectivity)
    #     - A collectivity is assigned to the report
    #     - The new package inherits the same collectivity
    #
    package { association(:package, collectivity: collectivity || build(:collectivity)) }

    commune
    action  { Report::ACTIONS.sample }
    subject { Report::SUBJECTS.sample }

    sequence(:reference) do |n|
      index = n.to_s.rjust(5, "0")
      "#{package.reference}-#{index}"
    end

    after(:build) do |report|
      report.collectivity         ||= report.package&.collectivity || build(:collectivity)
      report.package.collectivity ||= report.collectivity
    end

    trait :high_priority do
      priority { "high" }
    end

    trait :discarded do
      discarded_at { Time.current }
    end

    trait :approved do
      approved_at { Time.current }
    end

    trait :rejected do
      rejected_at { Time.current }
    end

    trait :debated do
      debated_at { Time.current }
    end
  end
end
