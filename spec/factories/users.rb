# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    transient do
      skip_confirmation_notification { true }
    end

    organization { association %i[publisher collectivity ddfip].sample }

    first_name   { Faker::Name.first_name }
    last_name    { Faker::Name.last_name }
    password     { Faker::Internet.password(min_length: Devise.password_length.min) }
    confirmed_at { Time.current }

    sequence :email do |n|
      name   = "#{first_name} #{last_name} #{n}"
      domain = organization&.domain_restriction

      Faker::Internet.email(name: name, domain: domain)
    end

    # Always skip notification by default
    # - it produces less logs
    # - it avoids extending the unconfirmed period when manually set
    #
    after :build do |user, evaluator|
      user.skip_confirmation_notification! if evaluator.skip_confirmation_notification
    end

    after :stub do |user, _evaluator|
      user.generate_name
    end

    trait :unconfirmed do
      confirmed_at         { nil }
      confirmation_token   { Devise.friendly_token }
      confirmation_sent_at { Time.current }
    end

    trait :to_reconfirmed do
      sequence :unconfirmed_email do |n|
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

    trait :form_admin do
      organization { association(:ddfip) }
      form_admin { true }

      transient do
        form_types { Report::FORM_TYPES.sample(2) }
      end

      user_form_types do
        form_types.map do |form_type|
          association :user_form_type, user: instance, form_type: form_type
        end
      end
    end

    trait :supervisor do
      organization { association(:ddfip, :with_offices) }

      transient do
        office_users_size { 1 }
      end

      office_users do
        Array.new(office_users_size) do |index|
          association :office_user, supervisor: true, office: instance.organization.offices[index], user: instance
        end
      end
    end

    trait :using_existing_organizations do
      organization do
        [DDFIP, Publisher, Collectivity].sample.order("RANDOM()").first ||
          association(%i[publisher collectivity ddfip].sample)
      end
    end
  end
end
