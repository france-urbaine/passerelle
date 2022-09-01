# frozen_string_literal: true

FactoryBot.define do
  factory :service_commune do
    association :service
    association :commune
  end
end
