# frozen_string_literal: true

module Users
  class RegistrationPasswordsController < ApplicationController
    skip_before_action :authenticate_user!
    before_action :sign_out, only: :new

    before_action do
      @user = User.find_by_invitation_token(params[:token])
      redirect_to new_user_session_path, notice: t("users.registrations.token_expired") if @user.errors.any?
    end

    layout "public"

    def new; end

    def create
      @user.skip_password_change_notification!
      @user.update(user_params)

      respond_with @user,
        notice: t(".success"),
        location: new_user_registration_two_factor_path(confirmation_token: params[:confirmation_token])
    end

    protected

    def user_params
      params
        .fetch(:user, {})
        .permit(:password, :password_confirmation)
    end
  end
end
