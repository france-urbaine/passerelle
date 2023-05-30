# frozen_string_literal: true

module Users
  class UserSettingsController < ApplicationController
    before_action { authorize! with: Users::UserSettingsPolicy }

    def show
      @user          = current_user
      @user_email    = duplicate_user_to_update_email(current_user)
      @user_password = duplicate_user_to_update_password(current_user)
    end

    def update
      @user = User.find(current_user.id)
      return gone(@user) if @user.discarded?

      if request_for_reconfirmation_instructions?(@user)
        @user.send_reconfirmation_instructions
        notice = translate(".send_reconfirmation_instructions")

      elsif request_to_cancel_pending_reconfirmation?(@user)
        @user.cancel_pending_reconfirmation
        notice = translate(".cancel_pending_reconfirmation")

      else
        @user.update_with_password_protection(user_params)

        # Dpicate users to display errors properly for each concern
        #
        if @user.errors.any?
          @user_email    = duplicate_user_to_update_email(@user)
          @user_password = duplicate_user_to_update_password(@user)
        end

        # Warden automatically signs out user when credentials changed
        # Let's keep user signed in after updating password.
        #
        bypass_sign_in @user
      end

      respond_with @user,
        action: :show,
        flash:  true,
        notice: notice,
        location: user_settings_path
    end

    def request_for_reconfirmation_instructions?(user)
      params[:send_reconfirmation_instructions] && user.pending_reconfirmation?
    end

    def request_to_cancel_pending_reconfirmation?(user)
      params[:cancel_pending_reconfirmation] && user.pending_reconfirmation?
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
      new_user.errors.merge!(user.errors) if user_params.include?(:password)
      new_user
    end
  end
end
