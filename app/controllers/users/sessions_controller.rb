# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    layout "public"

    private

    # Intercept flash message to avoid setting a notice
    # when user is logged in.
    #
    def set_flash_message!(key, kind, options = {})
      super(key, kind, options) unless kind == :signed_in
    end
  end
end
