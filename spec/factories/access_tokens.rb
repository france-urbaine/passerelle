# frozen_string_literal: true

FactoryBot.define do
  factory :doorkeeper_access_token, class: "Doorkeeper::AccessToken" do
    association :application, factory: :oauth_application # rubocop:disable FactoryBot/AssociationStyle
  end
end
