# frozen_string_literal: true

FactoryBot.define do
  factory :workshop do
    ddfip
    name { Faker::Book.title }
  end
end
