# frozen_string_literal: true

FactoryBot.define do
  factory :departement do
    association :region

    name { Faker::Address.state }

    code_departement do
      loop do
        value = Faker::Address.zip_code[0..1]
        break value unless Departement.exists?(code_departement: value)
      end
    end
  end
end
