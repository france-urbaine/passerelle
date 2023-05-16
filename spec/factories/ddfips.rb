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

    name do
      value = "DDFIP de #{departement&.name || Faker::Address.state}"
      next value unless DDFIP.exists?(name: value)

      loop do
        value = "DDFIP de #{Faker::Address.city}"
        break value unless DDFIP.exists?(name: value)
      end
    end

    trait :discarded do
      discarded_at { Time.current }
    end
  end
end
