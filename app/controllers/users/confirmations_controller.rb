# frozen_string_literal: true

module Users
  class ConfirmationsController < Devise::ConfirmationsController
    layout "public"

    private

    # Intercept flash message to set a different message
    # wether the user is already logged or not,
    # wether it's a first confirmation or a reconfirmation
    #
    def set_flash_message!(key, kind, options = {})
      if kind == :confirmed
        kind = :reconfirmed if resource.unconfirmed_email_previously_changed?(to: nil)
        kind = :"#{kind}_already_signed_in" if user_signed_in?
      end

      super(key, kind, options)
    end
  end
end
