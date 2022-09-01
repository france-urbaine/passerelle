# frozen_string_literal: true

FactoryBot.define do
  factory :service do
    association :ddfip

    title  { Faker::Book.title }
    action { %w[evaluation_hab evaluation_eco occupation_hab occupation_eco].sample }

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
