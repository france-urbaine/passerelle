# frozen_string_literal: true

FactoryBot.define do
  factory :ddfip do
    transient do
      name_pattern { "DDFIP de %{deparement} #%{sequence}" }
    end

    departement do
      if @build_strategy.to_sym == :create && Departement.count >= 10
        Departement.order("RANDOM()").first
      else
        association :departement
      end
    end

    sequence :name do |n|
      # Remove the sequence number added by departement factory (if it exists)
      # before interpolating it to the name pattern
      departement_name = departement&.name&.gsub(/\s*#\d+/, "") || Faker::Address.state

      name_pattern % { deparement: departement_name, sequence: n }
    end

    trait :discarded do
      discarded_at { Time.current }
    end

    trait :with_users do
      transient do
        users_size { 1 }
      end

      users do
        Array.new(users_size) do
          association :user, organization: instance
        end
      end
    end
  end
end
