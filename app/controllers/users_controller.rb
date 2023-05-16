# frozen_string_literal: true

class UsersController < ApplicationController
  before_action do
    @users_scope ||= User.all
  end

  def index
    return not_implemented if autocomplete_request?
    return redirect_to(@parent, status: :see_other) if @parent && !turbo_frame_request?

    @users = @users_scope.kept.strict_loading
    @users, @pagy = index_collection(@users, nested: @parent)
  end

  def show
    @user = @users_scope.find(params[:id])
    gone(@user) if @user.discarded?
  end

  def new
    @user = @users_scope.build
    @background_url = referrer_path || parent_path || users_path
  end

  def edit
    @user = @users_scope.find(params[:id])
    return gone(@user) if @user.discarded?

    @background_url = referrer_path || user_path(@user)
  end

  def remove
    @user = @users_scope.find(params[:id])
    return gone(@user) if @user.discarded?

    @background_url = referrer_path || user_path(@user)
  end

  def remove_all
    @users = @users_scope.kept.strict_loading
    @users = filter_collection(@users)
    @background_url = referrer_path || users_path(**selection_params)
  end

  def create
    @user = @users_scope.build(user_params)
    @user.invite(by: current_user)
    @user.save

    respond_with @user,
      flash: true,
      location: -> { redirect_path || parent_path || users_path }
  end

  def update
    @user = @users_scope.find(params[:id])
    return gone(@user) if @user.discarded?

    @user.update(user_params)

    respond_with @user,
      flash: true,
      location: -> { redirect_path || users_path }
  end

  def destroy
    @user = @users_scope.find(params[:id])
    @user.discard

    respond_with @user,
      flash: true,
      actions: FlashAction::Cancel.new(params),
      location: redirect_path || users_path
  end

  def undiscard
    @user = @users_scope.find(params[:id])
    @user.undiscard

    respond_with @user,
      flash: true,
      location: redirect_path || referrer_path || users_path
  end

  def destroy_all
    @users = @users_scope.kept.strict_loading
    @users = filter_collection(@users)
    @users.quickly_discard_all

    respond_with @users,
      flash: true,
      actions: FlashAction::Cancel.new(params),
      location: redirect_path || parent_path || users_path
  end

  def undiscard_all
    @users = @users_scope.discarded.strict_loading
    @users = filter_collection(@users)
    @users.quickly_undiscard_all

    respond_with @users,
      flash: true,
      location: redirect_path || referrer_path || parent_path || users_path
  end

  private

  def parent_path
    url_for(@parent) if @parent
  end

  def user_params
    params
      .fetch(:user, {})
      .then { |input| UserParamsParser.new(input, @parent).parse }
      .permit(
        :organization_type, :organization_id,
        :first_name, :last_name, :email,
        :organization_admin, :super_admin,
        office_ids: []
      )
  end
end
