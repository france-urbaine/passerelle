# frozen_string_literal: true

FactoryBot.define do
  factory :oauth_access_token do
    application { association :oauth_application }
  end
end
