# frozen_string_literal: true

FactoryBot.define do
  factory :publisher do
    name do
      loop do
        value = Faker::Company.name
        break value unless Publisher.exists?(name: value)
      end
    end

    siren { Faker::Company.french_siren_number }
  end
end
