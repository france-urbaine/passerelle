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

    name do
      loop do
        value = Faker::Address.state
        break value unless Departement.exists?(name: value) || Region.exists?(name: value)
      end
    end
  end
end
