# frozen_string_literal: true

module Users
  class InvitationsController < ApplicationController
    skip_before_action :authenticate_user!

    layout "public"

    def edit
      @user = User.find_by_invitation_token(params[:confirmation_token])

      if @user.errors.any?
        redirect_to new_user_session_path, notice: t("devise.invitation.expired")
      end
    end

    def update
      @user = User.find_by_invitation_token(params[:confirmation_token])
      @user.accept_invitation(user_params)

      respond_with @user,
        notice: t("devise.invitation.accepted"),
        location: new_session_path(@user)
    end

    protected

    def user_params
      params
        .fetch(:user, {})
        .permit(:password, :password_confirmation)
    end
  end
end
