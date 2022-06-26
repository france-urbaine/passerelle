# frozen_string_literal: true

FactoryBot.define do
  factory :collectivity do
    association :publisher
    territory { association %i[commune epci departement].sample }
    name      { territory.name }
    siren     { Faker::Company.french_siren_number }

    trait :orphan do
      publisher { nil }
    end

    trait :approved do
      approved_at { Time.current }
    end

    trait :discarded do
      discarded_at { Time.current }
    end

    trait :with_contact do
      contact_first_name  { Faker::Name.first_name }
      contact_last_name   { Faker::Name.last_name }
      contact_email       { Faker::Internet.email }
      contact_phone       { Faker::PhoneNumber.phone_number }
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

    trait :region do
      association :territory, factory: :region
    end
  end
end
