# frozen_string_literal: true

FactoryBot.define do
  factory :publisher do
    siren { Faker::Company.french_siren_number }

    name do
      loop do
        value = Faker::Company.name
        break value unless Publisher.exists?(name: value)
      end
    end

    trait :discarded do
      discarded_at { Time.current }
    end
  end
end
