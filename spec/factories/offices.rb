# frozen_string_literal: true

FactoryBot.define do
  factory :office do
    ddfip

    transient do
      name_pattern { "%{acronym} #%{sequence} de %{city}" }
    end

    sequence(:name) do |n|
      name_pattern % {
        acronym:  %w[SIE SIP PELP PELH SDIF].sample,
        city:     Faker::Address.city,
        sequence: n
      }
    end

    action { Office::ACTIONS.sample }

    trait :occupation_hab do
      action { "occupation_hab" }
    end

    trait :occupation_pro do
      action { "occupation_pro" }
    end

    trait :evaluation_pro do
      action { "evaluation_pro" }
    end

    trait :evaluation_hab do
      action { "evaluation_hab" }
    end

    trait :discarded do
      discarded_at { Time.current }
    end
  end
end
