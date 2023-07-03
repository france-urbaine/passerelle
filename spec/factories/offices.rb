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

    competences { [Office::COMPETENCES.sample] }

    Office::COMPETENCES.each do |competence|
      trait competence do
        competences { [competence] }
      end
    end

    trait :discarded do
      discarded_at { Time.current }
    end

    trait :with_communes do
      transient do
        communes_size { 1 }
      end

      communes do
        Array.new(communes_size) do
          association(:commune, departement: ddfip.departement)
        end
      end
    end
  end
end
