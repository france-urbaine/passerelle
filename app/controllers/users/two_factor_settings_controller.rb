# frozen_string_literal: true

module Users
  class TwoFactorSettingsController < ApplicationController
    def new
      @user = current_user
      redirect_to action: :edit unless @user.organization&.allow_2fa_via_email?
    end

    def create
      otp_method = params
        .fetch(:user, {})
        .permit(:otp_method)
        .fetch(:otp_method)

      redirect_to action: :edit, params: { otp_method: otp_method }
    end

    def edit
      @user = current_user
      @user.generate_two_factor_secret_if_missing

      @user.otp_method = params[:otp_method] if params[:otp_method]
      @user.otp_method = "2fa" unless @user.organization&.allow_2fa_via_email?

      Users::Mailer.two_factor_setup_code(@user).deliver_now if @user.send_otp_code_by_email?
    end

    def update
      @user = current_user
      @user.enable_two_factor_with_password(otp_activation_params)

      respond_with @user,
        notice: translate(@user.otp_required_for_login_previously_changed?(from: false) ? ".activated" : ".updated"),
        location: user_settings_path
    end

    private

    def otp_activation_params
      params
        .fetch(:user, {})
        .permit(:otp_code, :otp_method, :current_password)
    end
  end
end
