# frozen_string_literal: true

FactoryBot.define do
  factory :epci do
    transient do
      name_pattern { "%{type} %{city} #%{sequence}" }
    end

    siren { Faker::Company.french_siren_number }

    sequence :name do |n|
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
