# frozen_string_literal: true

FactoryBot.define do
  factory :ddfip do
    association :departement
    name { departement&.name }
  end
end
