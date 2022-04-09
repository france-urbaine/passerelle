# frozen_string_literal: true

FactoryBot.define do
  factory :commune do
    name do
      loop do
        value = Faker::Address.city
        break value unless Commune.exists?(name: value)
      end
    end

    code_insee       { Faker::Address.zip_code }
    code_departement { code_insee[0..1] }
  end
end
