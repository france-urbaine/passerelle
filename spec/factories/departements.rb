# frozen_string_literal: true

FactoryBot.define do
  factory :departement do
    name do
      loop do
        value = Faker::Address.state
        break value unless Departement.exists?(name: value)
      end
    end

    code_departement do
      loop do
        value = Faker::Address.zip_code[0..1]
        break value unless Departement.exists?(code_departement: value)
      end
    end

    code_region { Faker::Address.zip_code[0..1] }
  end
end
