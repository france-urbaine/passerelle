# frozen_string_literal: true

module Admin
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
      @user = build_user
      @referrer_path = referrer_path || admin_users_path
    end

    def create
      @user = build_user
      service = ::Users::CreateService.new(@user, user_params, invited_by: current_user)
      result  = service.save

      respond_with result,
        flash: true,
        location: -> { redirect_path || admin_users_path }
    end

    def edit
      @user = find_and_authorize_user
      @referrer_path = referrer_path || admin_user_path(@user)
    end

    def update
      @user = find_and_authorize_user
      service = ::Users::UpdateService.new(@user, user_params)
      result  = service.save

      respond_with result,
        flash: true,
        location: -> { redirect_path || admin_users_path }
    end

    def remove
      @user = find_and_authorize_user
      @referrer_path = referrer_path || admin_user_path(@user)
      @redirect_path = referrer_path unless referrer_path&.include?(admin_user_path(@user))
    end

    def destroy
      @user = find_and_authorize_user(allow_discarded: true)
      @user.discard

      respond_with @user,
        flash: true,
        actions: undiscard_admin_user_action(@user),
        location: redirect_path || admin_users_path
    end

    def undiscard
      @user = find_and_authorize_user(allow_discarded: true)
      @user.undiscard

      respond_with @user,
        flash: true,
        location: redirect_path || referrer_path || admin_users_path
    end

    def remove_all
      @users = authorize_users_scope
      @users = filter_collection(@users)
      @referrer_path = referrer_path || admin_users_path(**selection_params)
    end

    def destroy_all
      @users = authorize_users_scope(as: :destroyable)
      @users = filter_collection(@users)
      @users.quickly_discard_all

      respond_with @users,
        flash: true,
        actions: undiscard_all_admin_users_action,
        location: redirect_path || admin_users_path
    end

    def undiscard_all
      @users = authorize_users_scope(as: :undiscardable)
      @users = filter_collection(@users)
      @users.quickly_undiscard_all

      respond_with @users,
        flash: true,
        location: redirect_path || referrer_path || admin_users_path
    end

    private

    def authorize_users_scope(as: :default)
      authorized(User.all, as:).strict_loading
    end

    def build_user(...)
      authorize_users_scope.build(...)
    end

    def find_and_authorize_user(allow_discarded: false)
      user = User.find(params[:id])

      authorize! user
      only_kept! user unless allow_discarded

      user
    end

    def user_params
      authorized(params.fetch(:user, {}))
    end
  end
end
