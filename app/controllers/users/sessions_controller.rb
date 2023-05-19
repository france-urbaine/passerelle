# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    include AuthenticateWithOtpTwoFactor

    # From https://github.com/gitlabhq/gitlabhq/blob/master/app/controllers/sessions_controller.rb
    #
    # protect_from_forgery is already prepended in ApplicationController but
    # authenticate_with_two_factor which signs in the user is prepended before
    # that here.
    #
    # We need to make sure CSRF token is verified before authenticating the user
    # because Devise.clean_up_csrf_token_on_authentication is set to true by
    # default to avoid CSRF token fixation attacks. Authenticating the user first
    # would cause the CSRF token to be cleared and then
    # RequestForgeryProtection#verify_authenticity_token would fail because of
    # token mismatch.
    #
    prepend_before_action :authenticate_with_two_factor, only: :create # rubocop:disable Rails/LexicallyScopedActionFilter
    protect_from_forgery with: :exception, prepend: true, except: :destroy

    layout "public"

    private

    # Intercept flash message to avoid setting a notice
    # when user is logged in.
    #
    def set_flash_message!(key, kind, options = {})
      super(key, kind, options) unless kind == :signed_in
    end

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_in, keys: %i[otp_attempt])
    end
  end
end
