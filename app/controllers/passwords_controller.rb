# frozen_string_literal: true

class PasswordsController < ApplicationController
  skip_after_action :verify_authorized

  def strength_test
    return not_acceptable unless turbo_frame_request?

    @checked_password = Zxcvbn.test(password_params) unless password_params.empty?
  end

  private

  def password_params
    params.fetch(:password)
  end
end
