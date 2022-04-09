# frozen_string_literal: true

FactoryBot.define do
  factory :collectivity do
    association :publisher

    # TODO: use a proper association
    territory_id   { Faker::Internet.uuid }
    territory_type { %w[Commune EPCI Departement].sample }

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
      territory_type { "Commune" }
    end

    trait :epci do
      territory_type { "EPCI" }
    end

    trait :departement do
      territory_type { "Departement" }
    end
  end
end
