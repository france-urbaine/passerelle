# frozen_string_literal: true

FactoryBot.define do
  factory :publisher do
    siren { Faker::Company.french_siren_number }

    sequence :name do |n|
      "#{Faker::Company.name} ##{n}"
    end

    trait :discarded do
      discarded_at { Time.current }
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
