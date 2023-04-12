# frozen_string_literal: true

FactoryBot.define do
  factory :office_commune do
    association :office
    association :commune
  end
end
