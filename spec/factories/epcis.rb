# frozen_string_literal: true

FactoryBot.define do
  factory :epci do
    siren { Faker::Company.french_siren_number }

    name do
      loop do
        value = "Agglomération de #{Faker::Address.city}"
        break value unless EPCI.exists?(name: value)
      end
    end

    trait :with_departement do
      association :departement
    end
  end
end
