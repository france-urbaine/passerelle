# frozen_string_literal: true

module Admin
  module Publishers
    class UsersController < ApplicationController
      before_action :authorize!
      before_action :load_and_authorize_publisher
      before_action :autocompletion_not_implemented!, only: :index
      before_action :better_view_on_publisher, only: :index

      def index
        @users = authorize_users_scope
        @users, @pagy = index_collection(@users, nested: true)
      end

      def new
        @user = build_user
        @referrer_path = referrer_path || admin_publisher_path(@publisher)
      end

      def create
        @user = build_user
        service = ::Users::CreateService.new(@user, user_params, invited_by: current_user, organization: @publisher)
        result = service.save

        respond_with result,
          flash: true,
          location: -> { redirect_path || admin_publisher_path(@publisher) }
      end

      def remove_all
        @users = authorize_users_scope
        @users = filter_collection(@users)
        @referrer_path = referrer_path || admin_publisher_path(@publisher)
      end

      def destroy_all
        @users = authorize_users_scope(as: :destroyable)
        @users = filter_collection(@users)
        @users.quickly_discard_all

        respond_with @users,
          flash: true,
          actions: undiscard_all_admin_publisher_users_action,
          location: redirect_path || admin_publisher_path(@publisher)
      end

      def undiscard_all
        @users = authorize_users_scope(as: :undiscardable)
        @users = filter_collection(@users)
        @users.quickly_undiscard_all

        respond_with @users,
          flash: true,
          location: redirect_path || referrer_path || admin_publisher_path(@publisher)
      end

      private

      def load_and_authorize_publisher
        @publisher = Publisher.find(params[:publisher_id])

        authorize! @publisher, to: :show?
        only_kept! @publisher
      end

      def better_view_on_publisher
        return if turbo_frame_request?
        return if params.key?(:debug)

        redirect_to admin_publisher_path(@publisher), status: :see_other
      end

      def authorize_users_scope(as: :default)
        authorized(@publisher.users.all, as:).strict_loading
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
