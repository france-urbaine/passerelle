# frozen_string_literal: true

# Controller concern to handle two-factor authentication
# See https://github.com/gitlabhq/gitlabhq/blob/master/app/controllers/concerns/authenticates_with_two_factor.rb
#
module AuthenticateWithOtpTwoFactor
  extend ActiveSupport::Concern

  def authenticate_with_two_factor
    user = self.resource = find_user
    # return handle_locked_user(user) unless user.can?(:log_in)
    # return handle_changed_user(user) if user_password_changed?(user)

    if user_params.include?(:otp_attempt) && session[:otp_user_id]
      authenticate_with_two_factor_via_otp(user)
    elsif user && user.valid_password?(user_params[:password])
      Users::Mailer.two_factor_sign_in_code(user).deliver_now if user.send_otp_code_by_email?
      prompt_for_two_factor(user)
    end
  end

  private

  # Store the user's ID in the session for later retrieval and render the
  # two factor code prompt
  #
  # The user must have been authenticated with a valid login and password
  # before calling this method!
  #
  # user - User record
  #
  # Returns nil
  def prompt_for_two_factor(user)
    # Set @user for Devise views
    @user = user

    # return handle_locked_user(user) unless user.can?(:log_in)

    session[:otp_user_id] = user.id
    session[:user_password_hash] = Digest::SHA256.hexdigest(user.encrypted_password)

    render "users/sessions/two_factor", status: :unprocessable_entity
  end

  def authenticate_with_two_factor_via_otp(user)
    if valid_otp_attempt?(user)
      # Remove any lingering user data from login
      clear_two_factor_attempt!

      remember_me(user) if user_params[:remember_me] == "1"
      user.save!
      sign_in(user, event: :authentication)
    else
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

  def find_user
    @find_user ||=
      if session[:otp_user_id]
        User.find(session[:otp_user_id])
      elsif user_params[:email]
        User.find_for_authentication(email: user_params[:email])
      end
  end

  def two_factor_enabled?
    find_user&.otp_required_for_login?
  end
end
