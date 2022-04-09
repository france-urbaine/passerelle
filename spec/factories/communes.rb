# frozen_string_literal: true

FactoryBot.define do
  factory :commune do
    association :departement

    name do
      loop do
        value = Faker::Address.city
        break value unless Commune.exists?(name: value)
      end
    end

    code_insee do
      case departement&.code_departement&.size
      when 2 then "#{departement.code_departement}#{Faker::Number.number(digits: 3)}"
      when 3 then "#{departement.code_departement}#{Faker::Number.number(digits: 2)}"
      else Faker::Address.zip_code
      end
    end

    trait :with_epci do
      association :epci
    end
  end
end
