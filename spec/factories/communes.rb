# frozen_string_literal: true

FactoryBot.define do
  sequence(:code_insee) { Faker::Base.numerify("#####") }

  factory :commune do
    departement

    name do
      loop do
        value = Faker::Address.unique.city
        break value unless Commune.exists?(name: value)
      end
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
  end
end
