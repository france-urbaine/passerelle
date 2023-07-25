# frozen_string_literal: true

module Admin
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

      def new
        @user = build_user
        @referrer_path = referrer_path || admin_collectivity_path(@collectivity)
      end

      def create
        @user = build_user
        service = ::Users::CreateService.new(@user, user_params, invited_by: current_user, organization: @collectivity)
        result = service.save

        respond_with result,
          flash: true,
          location: -> { redirect_path || admin_collectivity_path(@collectivity) }
      end

      def remove_all
        @users = authorize_users_scope
        @users = filter_collection(@users)
        @referrer_path = referrer_path || admin_collectivity_path(@collectivity)
      end

      def destroy_all
        @users = authorize_users_scope(as: :destroyable)
        @users = filter_collection(@users)
        @users.quickly_discard_all

        respond_with @users,
          flash: true,
          actions: undiscard_all_admin_collectivity_users_action,
          location: redirect_path || admin_collectivity_path(@collectivity)
      end

      def undiscard_all
        @users = authorize_users_scope(as: :undiscardable)
        @users = filter_collection(@users)
        @users.quickly_undiscard_all

        respond_with @users,
          flash: true,
          location: redirect_path || referrer_path || admin_collectivity_path(@collectivity)
      end

      private

      def load_and_authorize_collectivity
        @collectivity = Collectivity.find(params[:collectivity_id])

        authorize! @collectivity, to: :show?
        only_kept! @collectivity
      end

      def better_view_on_collectivity
        return if turbo_frame_request?
        return if params.key?(:debug)

        redirect_to admin_collectivity_path(@collectivity), status: :see_other
      end

      def authorize_users_scope(as: :default)
        authorized(@collectivity.users.all, as:).strict_loading
      end

      def build_user(...)
        authorize_users_scope.build(...)
      end

      def user_params
        authorized(params.fetch(:user, {}))
      end
    end
  end
end
