# frozen_string_literal: true

FactoryBot.define do
  factory :collectivity do
    transient do
      name_pattern { ENV["APIPIE_RECORD"] ? "%{territory}" : "%{territory} #%{sequence}" }
    end

    publisher
    territory { association %i[commune epci departement].sample }
    siren     { Faker::Company.unique.french_siren_number }

    sequence :name do |n|
      # Remove the sequence number added by territory factory (if it exists)
      # before interpolating it to the name pattern
      territory_name = territory.name.gsub(/\s*#\d+/, "")

      name_pattern % { territory: territory_name, sequence: n }
    end

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
      territory factory: :commune
    end

    trait :epci do
      territory factory: :epci
    end

    trait :departement do
      territory factory: :departement
    end

    trait :region do
      territory factory: :region
    end

    trait :with_users do
      transient do
        users_size { 1 }
      end

      users do
        Array.new(users_size) do
          association :user, organization: instance
        end
      end
    end
  end
end
