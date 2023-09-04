# frozen_string_literal: true

FactoryBot.define do
  factory :oauth_application do
    owner { association :publisher }

    sequence(:name) { |n| "Application #{n}" }

    trait :discarded do
      discarded_at { Time.current }
    end
  end
end
