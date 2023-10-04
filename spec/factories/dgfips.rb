# frozen_string_literal: true

FactoryBot.define do
  factory :dgfip do
    contact_first_name { Faker::Name.first_name }
    contact_last_name  { Faker::Name.last_name }
    contact_email      { "#{contact_last_name.parameterize}@dgfip.test" }

    sequence :name do |n|
      "Ministère des finances ##{n}"
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
