# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    organization { association %i[publisher collectivity ddfip].sample }

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
      organization factory: :publisher
    end

    trait :collectivity do
      organization factory: :collectivity
    end

    trait :ddfip do
      organization factory: :ddfip
    end
  end
end
