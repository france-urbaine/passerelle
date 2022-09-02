# frozen_string_literal: true

FactoryBot.define do
  factory :service do
    association :ddfip

    name   { Faker::Book.title }
    action { Service::ACTIONS.sample }

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
  end
end
