# frozen_string_literal: true

module Users
  class MailerPreview < ActionMailer::Preview
    def registration_instructions
      user = FactoryBot.build(:user, :unconfirmed)

      Users::Mailer.confirmation_instructions(user, token)
    end

    def reconfirmation_instructions
      user = FactoryBot.build(:user, :to_reconfirmed)

      Users::Mailer.confirmation_instructions(user, token)
    end

    def reset_password_instructions
      Users::Mailer.reset_password_instructions(user, token)
    end

    def unlock_instructions
      Users::Mailer.unlock_instructions(user, token)
    end

    def email_changed
      Users::Mailer.email_changed(user)
    end

    def password_change
      Users::Mailer.password_change(user)
    end

    def two_factor_setup_code
      user = FactoryBot.build(:user, :with_otp)

      Users::Mailer.two_factor_setup_code(user)
    end

    def two_factor_sign_in_code
      user = FactoryBot.build(:user, :with_otp)

      Users::Mailer.two_factor_sign_in_code(user)
    end

    def two_factor_change
      Users::Mailer.two_factor_change(user)
    end

    private

    def token
      Devise.friendly_token
    end

    def user
      FactoryBot.build(:user)
    end
  end
end


