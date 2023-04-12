# frozen_string_literal: true

FactoryBot.define do
  factory :office_user do
    association :office
    association :user
  end
end
