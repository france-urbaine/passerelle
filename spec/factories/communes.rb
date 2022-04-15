# frozen_string_literal: true

FactoryBot.define do
  factory :commune do
    association :departement

    name       { Faker::Address.city }
    code_insee { Faker::Address.zip_code }

    trait :with_epci do
      association :epci
    end
  end
end
