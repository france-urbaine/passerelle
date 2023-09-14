# frozen_string_literal: true

module Organization
  module Collectivities
    module Users
      class InvitationsController < ApplicationController
        before_action :authorize_to_manage_collectivity_users!
        before_action :load_and_authorize_collectivity

        def new
          @user = load_and_authorize_user
          @referrer_path = referrer_path || organization_collectivity_user_path(@collectivity, @user)
        end

        def create
          @user  = load_and_authorize_user
          result = @user.resend_confirmation_instructions

          # Devise may applies errors if user is already confirmed
          @user.errors.clear

          respond_with @user,
            flash: result,
            location: -> { redirect_path || organization_collectivity_user_path(@collectivity, @user) }
        end

        private

        def authorize_to_manage_collectivity_users!
          authorize! User, to: :manage?, with: Organization::Collectivities::UserPolicy
        end

        def load_and_authorize_collectivity
          @collectivity = current_organization.collectivities.find(params[:collectivity_id])

          authorize! @collectivity, to: :show?
          only_kept! @collectivity

          # A first `authorize!` has been perfomed because of `before_action :authorize_to_manage_collectivity_users!`
          # It has been performed without collectivity in context to first know if
          # the current user may access to this controller.
          #
          # This second `authorize_to_manage_collectivity_users!` should be performed with the collectivity in context.
          #
          authorization_context[:collectivity] = @collectivity
          authorize_to_manage_collectivity_users!
        end

        def load_and_authorize_user
          user = @collectivity.users.find(params[:user_id])

          authorize! user, to: :manage?
          only_kept! user

          user
        end
      end
    end
  end
end
