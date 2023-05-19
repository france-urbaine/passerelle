# frozen_string_literal: true

module Users
  class UserSettingsController < ApplicationController
    def show
      @user          = current_user
      @user_email    = duplicate_user_to_update_email(current_user)
      @user_password = duplicate_user_to_update_password(current_user)
    end

    def update
      if params[:send_reconfirmation_instructions] && current_user.pending_reconfirmation?
        current_user.send_reconfirmation_instructions

        respond_with current_user,
          action: :show,
          notice: translate(".send_reconfirmation_instructions"),
          location: user_settings_path

      elsif params[:reset_email_reconfirmation] && current_user.pending_reconfirmation?
        current_user.update(unconfirmed_email: nil)

        respond_with current_user,
          action: :show,
          notice: translate(".reset_email_reconfirmation"),
          location: user_settings_path

      else
        @user = User.find(current_user.id)
        @user.update_with_password_protection(user_params)

        if @user.errors.any?
          @user_email    = duplicate_user_to_update_email(@user)
          @user_password = duplicate_user_to_update_password(@user)
        else
          # Warden automatically signs out user when credentials changed
          # Let's keep user signed in after updating password.
          #
          bypass_sign_in @user
        end

        respond_with @user,
          action: :show,
          flash:  true,
          location: user_settings_path
      end
    end

    private

    def user_params
      params
        .fetch(:user, {})
        .permit(
          :first_name, :last_name, :email,
          :password, :password_confirmation, :current_password
        )
    end

    def duplicate_user_to_update_email(user)
      new_user = user.dup

      if user_params.include?(:email)
        new_user.errors.merge!(user.errors)
      else
        new_user.email = ""
      end

      new_user
    end

    def duplicate_user_to_update_password(user)
      new_user = user.dup

      if user_params.include?(:password)
        new_user.errors.merge!(user.errors)
      end

      new_user
    end
  end
end
