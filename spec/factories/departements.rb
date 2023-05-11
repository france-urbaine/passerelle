# frozen_string_literal: true

FactoryBot.define do
  sequence(:code_departement) { Faker::Base.numerify("##") }

  factory :departement do
    region do
      if @build_strategy.to_sym == :create && Region.count >= 4
        Region.order("RANDOM()").first
      else
        association :region
      end
    end

    code_departement do
      loop do
        value = generate(:code_departement)
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
