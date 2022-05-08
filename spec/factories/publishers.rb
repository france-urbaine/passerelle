# frozen_string_literal: true

FactoryBot.define do
  factory :publisher do
    name  { Faker::Company.name }
    siren { Faker::Company.french_siren_number }

    trait :discarded do
      discarded_at { Time.current }
    end
  end
end
