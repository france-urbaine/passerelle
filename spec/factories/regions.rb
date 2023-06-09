# frozen_string_literal: true

FactoryBot.define do
  sequence(:code_region) { Faker::Base.numerify("##") }

  factory :region do
    code_region do
      loop do
        value = generate(:code_region)
        break value unless Region.exists?(code_region: value)
      end
    end

    sequence(:name) do |n|
      "#{Faker::Address.state} ##{n}"
    end
  end
end
