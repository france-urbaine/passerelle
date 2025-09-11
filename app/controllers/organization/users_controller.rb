# frozen_string_literal: true

module Organization
  class UsersController < ApplicationController
    before_action :authorize!
    before_action :autocompletion_not_implemented!, only: :index

    def index
      @users = authorize_users_scope
      @users, @pagy = index_collection(@users)
    end

    def show
      @user = find_and_authorize_user
    end

    def new
      @user = build_user(user_params)
      @referrer_path = referrer_path || organization_users_path
    end

    def create
      @user = build_user
      @user_params = user_params
      service = ::Users::CreateService.new(@user, @user_params,
        invited_by:   current_user,
        organization: current_organization)
      result = service.save

      if result.failure? && result.errors.of_kind?(:email, :taken)
        @other_user = User.find_by(email: @user.email)
        @referrer_path = referrer_path || organization_user_path(@user)

        render "email_taken"
      else
        respond_with result,
          flash: true,
          location: -> { redirect_path || organization_users_path }
      end
    end

    def edit
      @user = find_and_authorize_user
      @referrer_path = referrer_path || organization_user_path(@user)
    end

    def update
      @user = find_and_authorize_user
      service = ::Users::UpdateService.new(@user, user_params(as: :update))
      result  = service.save

      respond_with result,
        flash: true,
        location: -> { redirect_path || organization_users_path }
    end

    def remove
      @user = find_and_authorize_user
      @referrer_path = referrer_path || organization_user_path(@user)
      @redirect_path = referrer_path unless referrer_path&.include?(organization_user_path(@user))
    end

    def destroy
      @user = find_and_authorize_user(allow_discarded: true)
      @user.discard

      respond_with @user,
        flash: true,
        actions: undiscard_organization_user_action(@user),
        location: redirect_path || organization_users_path
    end

    def undiscard
      @user = find_and_authorize_user(allow_discarded: true)
      @user.undiscard

      respond_with @user,
        flash: true,
        location: redirect_path || referrer_path || organization_users_path
    end

    def remove_all
      @users = authorize_users_scope
      @users = filter_collection(@users)
      @referrer_path = referrer_path || organization_users_path(**selection_params)
    end

    def destroy_all
      @users = authorize_users_scope(as: :destroyable)
      @users = filter_collection(@users)
      @users.quickly_discard_all

      respond_with @users,
        flash: true,
        actions: undiscard_all_organization_users_action,
        location: redirect_path || organization_users_path
    end

    def undiscard_all
      @users = authorize_users_scope(as: :undiscardable)
      @users = filter_collection(@users)
      @users.quickly_undiscard_all

      respond_with @users,
        flash: true,
        location: redirect_path || referrer_path || organization_users_path
    end

    private

    def authorize_users_scope(as: :default)
      authorized(current_organization.users, as:).strict_loading
    end

    def build_user(...)
      authorize_users_scope.build(...)
    end

    def find_and_authorize_user(allow_discarded: false)
      user = current_organization.users.find(params[:id])

      authorize! user
      only_kept! user unless allow_discarded

      user
    end

    def user_params(as: :default)
      authorized(params.fetch(:user, {}), as:)
    end
  end
end
