# frozen_string_literal: true

FactoryBot.define do
  factory :package do
    collectivity
    name   { Faker::Book.title }
    action { Package::ACTIONS.sample }

    trait :transmitted do
      transmitted_at { Time.zone.now }
    end

    trait :approved do
      transmitted_at { Time.current }
      approved_at    { Time.current }
    end

    trait :rejected do
      transmitted_at { Time.current }
      rejected_at    { Time.current }
    end
  end
end
