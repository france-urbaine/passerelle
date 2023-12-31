# frozen_string_literal: true

module Admin
  module Users
    class ResetsController < ApplicationController
      def new
        @user          = load_and_authorize_user
        @referrer_path = referrer_path || admin_user_path(@user)
      end

      def create
        @user = load_and_authorize_user
        @user.reset_confirmation!

        result = @user.resend_confirmation_instructions

        respond_with @user,
          flash: result,
          location: -> { redirect_path || admin_user_path(@user) }
      end

      private

      def load_and_authorize_user
        user = User.find(params[:user_id])

        authorize! user, to: :reset?
        only_kept! user

        user
      end
    end
  end
end
