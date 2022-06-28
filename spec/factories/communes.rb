# frozen_string_literal: true

FactoryBot.define do
  factory :commune do
    association :departement

    name do
      loop do
        value = Faker::Address.city
        break value unless Departement.exists?(name: value)
      end
    end

    code_insee do
      loop do
        value = Faker::Address.zip_code
        break value unless Departement.exists?(name: value)
      end
    end

    trait :with_epci do
      association :epci
    end
  end
end
