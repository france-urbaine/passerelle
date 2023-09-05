# frozen_string_literal: true

module Users
  class TwoFactorSettingsController < ApplicationController
    before_action { authorize! with: Users::TwoFactorSettingsPolicy }

    def new
      return redirect_to action: :edit unless current_user.organization&.allow_2fa_via_email?

      @user = current_user
    end

    def create
      return redirect_to action: :edit unless current_user.organization&.allow_2fa_via_email?

      otp_method = params
        .fetch(:user, {})
        .permit(:otp_method)
        .fetch(:otp_method)

      redirect_to action: :edit, params: { otp_method: otp_method }
    end

    def edit
      @user = current_user
      @user.otp_secret = User.generate_otp_secret
      @user.otp_method = params[:otp_method] if params[:otp_method]
      @user.otp_method = "2fa" unless @user.organization&.allow_2fa_via_email?

      Users::Mailer.two_factor_setup_code(@user).deliver_later if @user.otp_method == "email"
    end

    def update
      @user = current_user
      @user.enable_two_factor_with_password(otp_activation_params)

      respond_with @user,
        notice: translate(".success"),
        location: user_settings_path
    end

    private

    def otp_activation_params
      params
        .fetch(:user, {})
        .permit(:otp_method, :otp_secret, :otp_code, :current_password)
    end
  end
end
