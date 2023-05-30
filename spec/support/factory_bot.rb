# frozen_string_literal: true

FactoryBot.define do
  after(:stub) do |object|
    # FactoryBot doesn't set up primary key ti stubbed records
    # because we use UUID everywhere instead of integers.
    object.id ||= SecureRandom.uuid
  end
end
