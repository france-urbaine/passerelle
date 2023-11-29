# frozen_string_literal: true

module Organization
  module Collectivities
    module Users
      class ResetsController < ApplicationController
        before_action :authorize_to_reset_collectivity_users!
        before_action :load_and_authorize_collectivity

        def new
          @user          = load_and_authorize_user
          @referrer_path = referrer_path || organization_collectivity_user_path(@collectivity, @user)
        end

        def create
          @user = load_and_authorize_user
          @user.reset_confirmation!

          result = @user.resend_confirmation_instructions

          respond_with @user,
            flash: result,
            location: -> { redirect_path || organization_collectivity_user_path(@collectivity, @user) }
        end

        private

        def authorize_to_reset_collectivity_users!
          authorize! User, to: :reset?, with: Organization::Collectivities::UserPolicy
        end

        def load_and_authorize_collectivity
          @collectivity = current_organization.collectivities.find(params[:collectivity_id])

          authorize! @collectivity, to: :show?
          only_kept! @collectivity

          authorization_context[:collectivity] = @collectivity
          authorize_to_reset_collectivity_users!
        end

        def load_and_authorize_user
          user = @collectivity.users.find(params[:user_id])

          authorize! user, to: :reset?
          only_kept! user

          user
        end
      end
    end
  end
end
