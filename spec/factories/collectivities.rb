# frozen_string_literal: true

FactoryBot.define do
  factory :collectivity do
    association :publisher
    territory { association %i[commune epci departement].sample }

    name do
      loop do
        value = Faker::Address.city
        break value unless Collectivity.exists?(name: value)
      end
    end

    siren { Faker::Company.french_siren_number }

    contact_first_name  { Faker::Name.first_name }
    contact_last_name   { Faker::Name.last_name }
    contact_email       { Faker::Internet.email }
    contact_phone       { Faker::PhoneNumber.phone_number }

    trait :orphan do
      publisher { nil }
    end

    trait :commune do
      association :territory, factory: :commune
    end

    trait :epci do
      association :territory, factory: :epci
    end

    trait :departement do
      association :territory, factory: :departement
    end
  end
end
