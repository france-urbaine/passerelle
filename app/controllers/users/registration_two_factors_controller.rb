# frozen_string_literal: true

module Users
  class RegistrationTwoFactorsController < ApplicationController
    skip_before_action :authenticate_user!
    before_action :sign_out, only: :new

    before_action do
      @user = User.find_by_invitation_token(params[:token])
      redirect_to new_user_session_path, notice: t("users.registrations.token_expired") if @user.errors.any?
    end

    layout "public"

    def new
      redirect_to action: :edit unless @user.organization&.allow_2fa_via_email?
    end

    def create
      return redirect_to action: :edit unless @user.organization&.allow_2fa_via_email?

      otp_method = params
        .fetch(:user, {})
        .permit(:otp_method)
        .fetch(:otp_method)

      redirect_to action: :edit, params: { otp_method: otp_method }
    end

    def edit
      @user.otp_secret = User.generate_otp_secret
      @user.otp_method = params[:otp_method] if params[:otp_method]
      @user.otp_method = "2fa" unless @user.organization&.allow_2fa_via_email?

      Users::Mailer.two_factor_setup_code(@user).deliver_now if @user.send_otp_code_by_email?
    end

    def update
      @user.enable_two_factor(otp_activation_params)
      @user.confirm

      respond_with @user,
        notice: t(".success"),
        location: new_session_path(@user)
    end

    protected

    def otp_activation_params
      params
        .fetch(:user, {})
        .permit(:otp_method, :otp_secret, :otp_code)
    end
  end
end
