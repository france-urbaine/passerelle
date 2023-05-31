# frozen_string_literal: true

module Users
  class Mailer < Devise::Mailer
    def confirmation_instructions(user, token, opts = {})
      opts[:subject] =
        if user.confirmed? && user.pending_reconfirmation?
          translate("devise.mailer.reconfirmation_instructions.subject")
        else
          translate("devise.mailer.confirmation_instructions.subject")
        end

      super(user, token, opts)
    end

    def two_factor_setup_code(user)
      @user = user
      mail to: user.email, subject: translate(".subject")
    end

    def two_factor_sign_in_code(user)
      @user = user
      mail to: user.email, subject: translate(".subject")
    end

    def two_factor_change(user)
      @user = user
      mail to: user.email, subject: translate(".subject")
    end
  end
end
