# frozen_string_literal: true

FactoryBot.define do
  factory :ddfip do
    association :departement
    name { departement&.name }

    trait :discarded do
      discarded_at { Time.current }
    end
  end
end
