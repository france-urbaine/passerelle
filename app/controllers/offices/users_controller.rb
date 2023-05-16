# frozen_string_literal: true

module Offices
  class UsersController < ApplicationController
    before_action do
      office = Office.find(params[:office_id])

      next gone(office) if office.discarded?
      next gone(office.ddfip) if office.ddfip.discarded?

      @office = office
      @users_scope = office.users
    end

    def index
      return not_implemented if autocomplete_request?
      return redirect_to(office_path(@office), status: :see_other) if @office && !turbo_frame_request?

      @users = @users_scope.kept.strict_loading
      @users, @pagy = index_collection(@users, nested: @office)
    end

    def new
      @user = @office.ddfip.users.build(offices: [@office])
      @background_url = referrer_path || office_path(@office)
    end

    def remove
      @user = @users_scope.find(params[:id])
      return gone(@user) if @user.discarded?

      @background_url = referrer_path || office_path(@office)
    end

    def edit_all
      @office_users_form = OfficeUsersForm.new(@office)
      @background_url = referrer_path || office_path(@office)
    end

    def remove_all
      @users = @users_scope.kept.strict_loading
      @users = filter_collection(@users)
      @background_url = referrer_path || office_path(@office)
    end

    def create
      @user = @office.ddfip.users.build(user_params)
      @user.invite(by: current_user)
      @user.save

      respond_with @user,
        flash: true,
        location: -> { redirect_path || office_path(@office) }
    end

    def destroy
      @user = @users_scope.find(params[:id])
      return gone(@user) if @user.discarded?

      @office.users.destroy(@user)

      respond_with @user,
        flash: true,
        location: redirect_path || office_path(@office)
    end

    def update_all
      @office_users_updater = OfficeUsersUpdater.new(@office)
      @office_users_updater.update(user_ids_params)

      respond_with @office_users_updater,
        flash: true,
        location: -> { redirect_path || office_path(@office) }
    end

    def destroy_all
      @users = @users_scope.kept.strict_loading
      @users = filter_collection(@users)
      @office.users.destroy(@users)

      respond_with @users,
        flash: true,
        location: redirect_path || office_path(@office)
    end

    private

    def user_params
      params
        .fetch(:user, {})
        .then { |input| UserParamsParser.new(input, @office.ddfip).parse }
        .permit(
          :organization_type, :organization_id,
          :first_name, :last_name, :email,
          :organization_admin, :super_admin,
          office_ids: []
        )
    end

    def user_ids_params
      params
        .fetch(:office_users, {})
        .slice(:user_ids)
        .permit(user_ids: [])
        .fetch(:user_ids, [])
    end
  end
end
