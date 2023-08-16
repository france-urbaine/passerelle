# frozen_string_literal: true

class PasswordsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_after_action :verify_authorized

  def strength_test
    return not_acceptable unless turbo_frame_request?

    @checked_password = Zxcvbn.test(password_params) if password_params.present?
  end

  private

  def password_params
    params.fetch(:password)
  end
end
