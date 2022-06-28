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

    trait :with_unique_name do
      name do
        loop do
          value = Faker::Address.state
          break value unless Departement.exists?(name: value)
        end
      end
    end
  end
end
