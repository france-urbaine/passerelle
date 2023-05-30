# frozen_string_literal: true

module Users
  class RegistrationsController < ApplicationController
    prepend_before_action :sign_out
    skip_before_action :authenticate_user!

    layout "public"

    def show
      @user = User.find_by_invitation_token(params[:token])
      redirect_to new_user_session_path, notice: t("users.registrations.token_expired") if @user.errors.any?
    end
  end
end
