# frozen_string_literal: true

module Offices
  class UsersController < ApplicationController
    before_action :authorize!
    before_action :find_and_authorize_office
    before_action :build_and_authorize_users_scope, except: %i[edit_all update_all]
    before_action :build_user,                      only: %i[new create]
    before_action :find_and_authorize_user,         only: %i[remove destroy]

    def index
      return not_implemented if autocomplete_request?
      return redirect_to(@office, status: :see_other) unless turbo_frame_request?

      @users = @users.kept.strict_loading
      @users, @pagy = index_collection(@users, nested: @office)
    end

    def new
      @background_url = referrer_path || office_path(@office)
    end

    def create
      @user.assign_attributes(user_params)
      @user.invite(by: current_user)
      @user.save

      respond_with @user,
        flash: true,
        location: -> { redirect_path || office_path(@office) }
    end

    def remove
      only_kept! @user
      @background_url = referrer_path || office_path(@office)
    end

    def destroy
      only_kept! @user
      @office.users.destroy(@user)

      respond_with @user,
        flash: true,
        location: redirect_path || office_path(@office)
    end

    def edit_all
      @office_users_form = OfficeUsersForm.new(@office)
      @background_url = referrer_path || office_path(@office)
    end

    def update_all
      @office_users_updater = OfficeUsersUpdater.new(@office)
      @office_users_updater.update(user_ids_params)

      respond_with @office_users_updater,
        flash: true,
        location: -> { redirect_path || office_path(@office) }
    end

    def remove_all
      @users = @users.kept.strict_loading
      @users = filter_collection(@users)
      @background_url = referrer_path || office_path(@office)
    end

    def destroy_all
      @users = @users.kept.strict_loading
      @users = filter_collection(@users)
      @office.users.destroy(@users)

      respond_with @users,
        flash: true,
        location: redirect_path || office_path(@office)
    end

    private

    def find_and_authorize_office
      @office = Office.find(params[:office_id])

      authorize! @office, to: :show?
      only_kept! @office
      only_kept! @office.ddfip
    end

    def build_and_authorize_users_scope
      @users = @office.users
      @users = authorized(@users)
    end

    def build_user
      @user = @office.ddfip.users.build(offices: [@office])
    end

    def find_and_authorize_user
      @user = @office.ddfip.users.find(params[:id])

      authorize! @user
    end

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
