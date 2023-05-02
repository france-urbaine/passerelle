# frozen_string_literal: true

FactoryBot.define do
  sequence(:code_departement) { Faker::Base.numerify("##") }

  factory :departement do
    association :region

    code_departement do
      loop do
        value = generate(:code_departement)
        break value unless Departement.exists?(code_departement: value)
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
