# frozen_string_literal: true

FactoryBot.define do
  factory :epci do
    name  { "Agglomération de #{Faker::Address.city}" }
    siren { Faker::Company.french_siren_number }

    trait :with_departement do
      association :departement
    end
  end
end
