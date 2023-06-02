# frozen_string_literal: true

FactoryBot.define do
  factory :report do
    commune
    action  { Report::ACTIONS.sample }
    subject { Report::SUBJECTS.sample }

    after(:build) do |report|
      report.collectivity ||= (report.package&.collectivity || build(:collectivity))
      report.package      ||= build(:package, collectivity: report.collectivity)
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
