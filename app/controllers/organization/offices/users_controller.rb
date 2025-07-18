# frozen_string_literal: true

module Organization
  module Offices
    class UsersController < ApplicationController
      before_action :authorize!
      before_action :load_and_authorize_office
      before_action :autocompletion_not_implemented!, only: :index
      before_action :better_view_on_office, only: :index

      def index
        @users = authorize_users_scope
        @users, @pagy = index_collection(@users, nested: true)
      end

      def new
        @user = build_user(office_ids: [@office.id])
        @referrer_path = referrer_path || organization_office_path(@office)
      end

      def create
        @user = build_user
        service = ::Users::CreateService.new(@user, user_params, invited_by: current_user, organization: @office.ddfip)
        result = service.save

        respond_with result,
          flash: true,
          location: -> { redirect_path || organization_office_path(@office) }
      end

      def remove
        @user = find_and_authorize_user
        @referrer_path = referrer_path || organization_office_path(@office)
      end

      def destroy
        @user = find_and_authorize_user
        @office.users.destroy(@user)

        respond_with @user,
          flash: true,
          location: redirect_path || organization_office_path(@office)
      end

      def edit_all
        @referrer_path = referrer_path || organization_office_path(@office)
      end

      def update_all
        office_params = params
          .fetch(:office, {})
          .slice(:user_ids)
          .permit(user_ids: [])

        service = ::Offices::UpdateService.new(@office, office_params)
        service.save

        respond_with service,
          flash: true,
          location: -> { redirect_path || organization_office_path(@office) }
      end

      def remove_all
        @users = authorize_users_scope
        @users = filter_collection(@users)
        @referrer_path = referrer_path || organization_office_path(@office)
      end

      def destroy_all
        @users = authorize_users_scope
        @users = filter_collection(@users)
        @office.users.destroy(@users)

        respond_with @users,
          flash: true,
          location: redirect_path || organization_office_path(@office)
      end

      private

      def load_and_authorize_office
        @office = current_organization.offices.find(params[:office_id])

        authorize! @office, to: :show?
        only_kept! @office

        # A first `authorize!` has been perfomed without office in context
        # to first know if the current user may access to this controller.
        #
        # This second `authorize!` should be performed with the office in context.
        #
        authorization_context[:office] = @office
        authorize!
      end

      def better_view_on_office
        return if turbo_frame_request?
        return if params.key?(:debug)

        redirect_to organization_office_path(@office), status: :see_other
      end

      def authorize_users_scope
        authorized(@office.users).strict_loading
      end

      def build_user(...)
        authorize_users_scope.build(...)
      end

      def find_and_authorize_user
        user = @office.ddfip.users.find(params[:id])

        authorize! user
        only_kept! user

        user
      end

      def user_params
        authorized(params.fetch(:user, {}))
      end
    end
  end
end
