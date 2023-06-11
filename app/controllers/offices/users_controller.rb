# frozen_string_literal: true

module Offices
  class UsersController < ApplicationController
    before_action :authorize!
    before_action :load_and_authorize_office
    before_action :autocompletion_not_implemented!, only: :index
    before_action :better_view_on_office, only: :index

    def index
      @users = build_and_authorize_scope
      @users, @pagy = index_collection(@users, nested: @office)
    end

    def new
      @user = build_user(office_ids: [@office.id])
      @background_url = referrer_path || office_path(@office)
    end

    def create
      @user = build_user(user_params)
      @user.invite(by: current_user)
      @user.save

      respond_with @user,
        flash: true,
        location: -> { redirect_path || office_path(@office) }
    end

    def remove
      @user = find_and_authorize_user
      @background_url = referrer_path || office_path(@office)
    end

    def destroy
      @user = find_and_authorize_user
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
      @users = build_and_authorize_scope
      @users = filter_collection(@users)
      @background_url = referrer_path || office_path(@office)
    end

    def destroy_all
      @users = build_and_authorize_scope
      @users = filter_collection(@users)
      @office.users.destroy(@users)

      respond_with @users,
        flash: true,
        location: redirect_path || office_path(@office)
    end

    private

    def load_and_authorize_office
      office = Office.find(params[:office_id])

      authorize! office, to: :show?
      only_kept! office
      only_kept! office.ddfip

      @office = office
    end

    def better_view_on_office
      return redirect_to(@office, status: :see_other) unless turbo_frame_request?
    end

    def build_and_authorize_scope
      authorized(@office.users).strict_loading
    end

    def build_user(...)
      scope = authorized(@office.ddfip.users).strict_loading
      scope.build(...)
    end

    def find_and_authorize_user(allow_discarded: false)
      user = @office.ddfip.users.find(params[:id])

      authorize! user
      only_kept! user unless allow_discarded

      user
    end

    def user_params
      authorized(params.fetch(:user, {}))
        .then { |input| UserParamsParser.new(input, @office.ddfip).parse }
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
