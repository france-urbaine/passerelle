# frozen_string_literal: true

FactoryBot.define do
  factory :epci do
    name do
      loop do
        value = Faker::Address.city
        break value unless EPCI.exists?(name: value)
      end
    end

    siren { Faker::Company.french_siren_number }

    trait :with_departement do
      association :departement
    end
  end
end
