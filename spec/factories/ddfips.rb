# frozen_string_literal: true

FactoryBot.define do
  factory :ddfip do
    association :departement

    name { "DDFIP de #{departement&.name || Faker::Address.state}" }

    trait :discarded do
      discarded_at { Time.current }
    end
  end
end
