# frozen_string_literal: true

FactoryBot.define do
  factory :region do
    code_region do
      loop do
        value = Faker::Address.zip_code[0..1]
        break value unless Region.exists?(code_region: value)
      end
    end

    name do
      loop do
        value = Faker::Address.state
        break value unless Region.exists?(name: value)
      end
    end
  end
end
