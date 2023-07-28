# frozen_string_literal: true

FactoryBot.define do
  sequence(:code_insee) { Faker::Base.numerify("#####") }

  factory :commune do
    departement

    sequence(:name) do |n|
      "#{Faker::Address.city} ##{n}"
    end

    code_insee do
      loop do
        value = Faker::Base.numerify(code_departement.to_s.ljust(5, "#"))
        break value unless Commune.exists?(code_insee: value)
      end
    end

    trait :with_epci do
      epci
    end

    after(:stub) do |commune, _evaluator|
      commune.generate_qualified_name
    end
  end
end
