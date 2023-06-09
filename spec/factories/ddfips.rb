# frozen_string_literal: true

FactoryBot.define do
  factory :ddfip do
    departement do
      if @build_strategy.to_sym == :create && Departement.count >= 10
        Departement.order("RANDOM()").first
      else
        association :departement
      end
    end

    transient do
      name_pattern { "DDFIP de %{deparement} #%{sequence}" }
    end

    sequence(:name) do |n|
      name_pattern % {
        deparement: departement&.name || Faker::Address.state,
        sequence:   n
      }
    end

    trait :discarded do
      discarded_at { Time.current }
    end
  end
end
