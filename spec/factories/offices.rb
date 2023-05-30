# frozen_string_literal: true

FactoryBot.define do
  factory :office do
    ddfip

    name do
      acronyms = %w[SIE SIP PELP PELH SDIF]

      loop do
        type = acronyms.sample
        city = Faker::Address.city
        value = "#{type} de #{city}"

        break value unless Office.exists?(ddfip_id: ddfip_id, name: value)
      end
    end

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
