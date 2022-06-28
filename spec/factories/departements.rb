# frozen_string_literal: true

FactoryBot.define do
  factory :departement do
    association :region

    code_departement do
      loop do
        value = Faker::Address.zip_code[0..1]
        break value unless Departement.exists?(code_departement: value)
      end
    end

    name do
      loop do
        value = Faker::Address.state
        break value unless Departement.exists?(name: value)
      end
    end
  end
end
