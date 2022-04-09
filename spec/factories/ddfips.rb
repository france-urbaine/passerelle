# frozen_string_literal: true

FactoryBot.define do
  factory :ddfip do
    name do
      loop do
        value = Faker::Address.state
        break value unless DDFIP.exists?(name: value)
      end
    end

    code_departement { Faker::Address.zip_code[0..1] }
  end
end
