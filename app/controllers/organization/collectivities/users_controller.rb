# frozen_string_literal: true

module Organization
  module Collectivities
    class UsersController < ApplicationController
      before_action :authorize!
      before_action :load_and_authorize_collectivity
      before_action :autocompletion_not_implemented!, only: :index
      before_action :better_view_on_collectivity, only: :index

      def index
        @users = authorize_users_scope
        @users, @pagy = index_collection(@users, nested: true)
      end

      def show
        @user = find_and_authorize_user
      end

      def new
        @user = build_user
        @referrer_path = referrer_path || organization_collectivity_path(@collectivity)
      end

      def create
        @user = build_user
        service = ::Users::CreateService.new(@user, user_params,
          invited_by:   current_user,
          organization: @collectivity)
        result = service.save

        respond_with result,
          flash: true,
          location: -> { redirect_path || organization_collectivity_path(@collectivity) }
      end

      def edit
        @user = find_and_authorize_user
        @referrer_path = referrer_path || organization_collectivity_user_path(@collectivity, @user)
      end

      def update
        @user = find_and_authorize_user
        service = ::Users::UpdateService.new(@user, user_params)
        result  = service.save

        respond_with result,
          flash: true,
          location: -> { redirect_path || organization_collectivity_path(@collectivity) }
      end

      def remove
        @user = find_and_authorize_user
        @referrer_path = referrer_path || organization_collectivity_user_path(@collectivity, @user)

        @redirect_path = referrer_path
        @redirect_path = nil if referrer_path&.include?(organization_collectivity_user_path(@collectivity, @user))
      end

      def destroy
        @user = find_and_authorize_user(allow_discarded: true)
        @user.discard

        respond_with @user,
          flash: true,
          actions: undiscard_organization_collectivity_user_action(@collectivity, @user),
          location: redirect_path || organization_collectivity_path(@collectivity)
      end

      def undiscard
        @user = find_and_authorize_user(allow_discarded: true)
        @user.undiscard

        respond_with @user,
          flash: true,
          location: redirect_path || referrer_path || organization_collectivity_path(@collectivity)
      end

      def remove_all
        @users = authorize_users_scope
        @users = filter_collection(@users)
        @referrer_path = referrer_path || organization_collectivity_path(@collectivity)
      end

      def destroy_all
        @users = authorize_users_scope(as: :destroyable)
        @users = filter_collection(@users)
        @users.quickly_discard_all

        respond_with @users,
          flash: true,
          actions: undiscard_all_organization_collectivity_users_action(@collectivity),
          location: redirect_path || organization_collectivity_path(@collectivity)
      end

      def undiscard_all
        @users = authorize_users_scope(as: :undiscardable)
        @users = filter_collection(@users)
        @users.quickly_undiscard_all

        respond_with @users,
          flash: true,
          location: redirect_path || referrer_path || organization_collectivity_path(@collectivity)
      end

      private

      def load_and_authorize_collectivity
        @collectivity = current_organization.collectivities.find(params[:collectivity_id])

        authorize! @collectivity, to: :show?
        only_kept! @collectivity

        # A first `authorize!` has been perfomed because of `before_action :authorize!`
        # It has been performed without collectivity in context to first know if
        # the current user may access to this controller.
        #
        # This second `authorize!` should be performed with the collectivity in context.
        #
        authorization_context[:collectivity] = @collectivity
        authorize!
      end

      def better_view_on_collectivity
        return if turbo_frame_request?
        return if params.key?(:debug)

        redirect_to organization_collectivity_path(@collectivity), status: :see_other
      end

      def authorize_users_scope(as: :default)
        authorized(@collectivity.users, as:).strict_loading
      end

      def build_user(...)
        authorize_users_scope.build(...)
      end

      def find_and_authorize_user(allow_discarded: false)
        user = @collectivity.users.find(params[:id])

        authorize! user
        only_kept! user unless allow_discarded

        user
      end

      def user_params
        authorized(params.fetch(:user, {}))
      end
    end
  end
end
