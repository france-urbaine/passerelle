# frozen_string_literal: true

FactoryBot.define do
  factory :user_service do
    association :service
    association :user
  end
end
