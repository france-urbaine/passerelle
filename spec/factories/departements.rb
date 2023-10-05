# frozen_string_literal: true

FactoryBot.define do
  sequence(:code_departement) { Faker::Base.numerify("##") }

  factory :departement do
    region do
      # Use existing regions when enought regions already exists in database
      # to avoid name congestion
      #
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

    sequence :name do |sequence|
      "#{Faker::Address.state} ##{sequence}"
    end

    after :stub do |departement, _evaluator|
      departement.generate_qualified_name
    end
  end
end
