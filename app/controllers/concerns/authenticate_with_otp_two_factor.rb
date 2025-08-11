# frozen_string_literal: true

# Controller concern to handle two-factor authentication
# This is copied from Gitlab concerns.
#
# See:
#   https://github.com/gitlabhq/gitlabhq/blob/master/app/controllers/concerns/authenticates_with_two_factor.rb
#
module AuthenticateWithOtpTwoFactor
  extend ActiveSupport::Concern

  # Authenticate user with 2FA
  #
  # First step is to validate user credentials (email/password),
  # cache the user's ID and then render the 2FA prompt.
  #
  # Second step is to validate OTP attempt and finally log in user.
  #
  def authenticate_with_two_factor
    if user_params.include?(:otp_attempt) && session[:otp_user_id]
      user = self.resource = find_user_for_authentication
      authenticate_with_two_factor_via_otp(user)
      return
    end

    # The user request a first step authentication
    # Clear any lingering user data from previous login attempts.
    clear_two_factor_attempt!
    user = self.resource = find_user_for_authentication
    return unless user&.valid_password?(user_params[:password])

    # Do not deliver this mail asynchronously to avoid any latency due to
    # busy queues.
    #
    Users::Mailer.two_factor_sign_in_code(user).deliver_now if user.send_otp_code_by_email?
    prompt_for_two_factor(user)
  end

  private

  # Store the user's ID in the session for later retrieval and render the
  # two factor code prompt
  #
  # The user must have been authenticated with a valid login and password
  # before calling this method!
  #
  def prompt_for_two_factor(user)
    # Set @user for Devise views
    @user = user

    session[:otp_user_id] = user.id
    session[:user_password_hash] = Digest::SHA256.hexdigest(user.encrypted_password)

    render "users/sessions/two_factor", status: :unprocessable_content
  end

  def authenticate_with_two_factor_via_otp(user)
    if valid_otp_attempt?(user)
      # Remove any lingering user data from login
      clear_two_factor_attempt!

      remember_me(user) if user_params[:remember_me] == "1"
      user.save!
      sign_in(user, event: :authentication)
    else
      user.increment_failed_attempts!
      user.errors.add(:otp_attempt, :invalid)
      prompt_for_two_factor(user)
    end
  end

  def valid_otp_attempt?(user)
    user.validate_and_consume_otp!(user_params[:otp_attempt])
  end

  def clear_two_factor_attempt!
    session.delete(:otp_user_id)
    session.delete(:user_password_hash)
  end

  def user_params
    params
      .require(:user)
      .permit(:email, :password, :remember_me, :otp_attempt)
  end

  def find_user_for_authentication
    user = find_user

    if user&.active_for_authentication?
      user
    else
      throw :warden, scope: :user, message: user&.inactive_message
    end
  end

  def find_user
    if session[:otp_user_id]
      User.find_by(id: session[:otp_user_id])
    elsif user_params[:email]
      User.find_for_authentication(email: user_params[:email])
    end
  end
end
