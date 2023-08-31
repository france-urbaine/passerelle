# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    organization { association %i[publisher collectivity ddfip].sample }

    first_name   { Faker::Name.first_name }
    last_name    { Faker::Name.last_name }
    password     { Faker::Internet.password(min_length: Devise.password_length.min) }
    confirmed_at { Time.current }

    sequence(:email) do |n|
      name   = "#{first_name} #{last_name} #{n}"
      domain = organization&.domain_restriction

      Faker::Internet.email(name: name, domain: domain)
    end

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

    after(:stub) do |user, _evaluator|
      user.generate_name
    end

    trait :unconfirmed do
      confirmed_at         { nil }
      confirmation_token   { Devise.friendly_token }
      confirmation_sent_at { Time.current }
    end

    trait :to_reconfirmed do
      sequence(:unconfirmed_email) do |n|
        name   = "#{first_name} #{last_name} #{n}"
        domain = organization&.domain_restriction

        Faker::Internet.email(name: name, domain: domain)
      end

      confirmation_token   { Devise.friendly_token }
      confirmation_sent_at { Time.current }
    end

    trait :with_otp do
      otp_secret { User.generate_otp_secret }
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

    trait :dgfip do
      organization { DGFIP.kept.first || build(:dgfip) }
    end

    trait :using_existing_organizations do
      organization do
        [DDFIP, Publisher, Collectivity].sample.order("RANDOM()").first ||
          association(%i[publisher collectivity ddfip].sample)
      end
    end
  end
end
