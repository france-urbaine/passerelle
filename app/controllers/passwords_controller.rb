# frozen_string_literal: true

class PasswordsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_after_action :verify_authorized

  def strength_test
    return not_acceptable unless turbo_frame_request?

    result = Zxcvbn.zxcvbn(password_params)

    @score       = result["score"]
    @warning     = result.dig("feedback", "warning").presence&.parameterize&.underscore
    @suggestions = result.dig("feedback", "suggestions").map do |suggestion|
      suggestion.parameterize.underscore
    end
  end

  private

  def password_params
    params.require(:password)
  end
end
