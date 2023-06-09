# frozen_string_literal: true

FactoryBot.define do
  factory :publisher do
    siren { Faker::Company.french_siren_number }

    sequence(:name) do |n|
      "#{Faker::Company.name} ##{n}"
    end

    trait :discarded do
      discarded_at { Time.current }
    end
  end
end
