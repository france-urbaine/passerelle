# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    # TODO: use a proper association
    organization_id   { Faker::Internet.uuid }
    organization_type { %w[Publisher Collectivity DDFIP].sample }

    first_name   { Faker::Name.first_name }
    last_name    { Faker::Name.last_name }
    password     { Faker::Internet.password }
    confirmed_at { Time.current }

    sequence(:email) { |n| Faker::Internet.safe_email(name: "#{first_name}_#{n}") }

    trait :unconfirmed do
      confirmed_at { nil }
    end

    trait :invited do
      inviter    { FactoryBot.build(:user) }
      invited_at { Time.current }
    end

    trait :super_admin do
      super_admin { true }
    end

    trait :organization_admin do
      organization_admin { true }
    end

    trait :publisher do
      organization_type { "Publisher" }
    end

    trait :collectivity do
      organization_type { "Collectivity" }
    end

    trait :ddfip do
      organization_type { "DDFIP" }
    end
  end
end
