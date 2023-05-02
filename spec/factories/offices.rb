# frozen_string_literal: true

FactoryBot.define do
  factory :office do
    association :ddfip

    name   { Faker::Book.title }
    action { Office::ACTIONS.sample }

    trait :occupation_hab do
      action { "occupation_hab" }
    end

    trait :occupation_eco do
      action { "occupation_eco" }
    end

    trait :evaluation_eco do
      action { "evaluation_eco" }
    end

    trait :evaluation_hab do
      action { "evaluation_hab" }
    end

    trait :discarded do
      discarded_at { Time.current }
    end
  end
end
