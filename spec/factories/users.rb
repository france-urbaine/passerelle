# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    organization { association %i[publisher collectivity ddfip].sample }

    first_name   { Faker::Name.first_name }
    last_name    { Faker::Name.last_name }
    password     { Faker::Internet.password(min_length: Devise.password_length.min) }
    confirmed_at { Time.current }

    sequence(:email) { |n| Faker::Internet.email(name: "#{first_name}_#{n}") }

    # Always skip notification by default
    # - it produces less logs
    # - it avoids extending the unconfirmed period when manually set
    #
    transient do
      skip_confirmation_notification { true }
    end

    after(:build) do |user, evaluator|
      user.skip_confirmation_notification! if evaluator.skip_confirmation_notification
    end

    trait :using_existing_organizations do
      organization do
        [DDFIP, Publisher, Collectivity].sample.order("RANDOM()").first ||
          association(%i[publisher collectivity ddfip].sample)
      end
    end

    trait :unconfirmed do
      confirmed_at { nil }
    end

    trait :invited do
      inviter    { FactoryBot.build(:user) }
      invited_at { Time.current }
    end

    trait :discarded do
      discarded_at { Time.current }
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
