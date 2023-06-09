# frozen_string_literal: true

FactoryBot.define do
  factory :epci do
    siren { Faker::Company.french_siren_number }

    transient do
      name_pattern { "%{type} %{city} #%{sequence}" }
    end

    sequence(:name) do |n|
      name_pattern % {
        type:     %w[CA CC CU Agglomération Metropole].sample,
        city:     Faker::Address.city,
        sequence: n
      }
    end

    trait :with_departement do
      departement
    end
  end
end
