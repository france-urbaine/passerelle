# frozen_string_literal: true

class UsersController < ApplicationController
  respond_to :html

  def index
    @users = User.kept.strict_loading
    @users, @pagy = index_collection(@users)

    respond_with @users do |format|
      format.html.autocomplete { not_implemented }
    end
  end

  def show
    @user = User.find(params[:id])
    gone(@user) if @user.discarded?
  end

  def new
    @user = User.new(user_params)
    @background_url = referrer_path || users_path
  end

  def edit
    @user = User.find(params[:id])
    return gone(@user) if @user.discarded?

    @background_url = referrer_path || user_path(@user)
  end

  def remove
    @user = User.find(params[:id])
    return gone(@user) if @user.discarded?

    @background_url = referrer_path || user_path(@user)
  end

  def remove_all
    @users = User.kept.strict_loading
    @users = filter_collection(@users)
    @background_url = referrer_path || users_path(**selection_params)
  end

  def create
    @user = User.new(user_params)
    @user.invite(by: current_user)
    @user.save

    respond_with @user,
      flash: true,
      location: -> { redirect_path || users_path }
  end

  def update
    @user = User.find(params[:id])
    return gone(@user) if @user.discarded?

    @user.update(user_params)

    respond_with @user,
      flash: true,
      location: -> { redirect_path || users_path }
  end

  def destroy
    @user = User.find(params[:id])
    @user.discard

    respond_with @user,
      flash: true,
      actions: FlashAction::Cancel.new(params),
      location: redirect_path || users_path
  end

  def undiscard
    @user = User.find(params[:id])
    @user.undiscard

    respond_with @user,
      flash: true,
      location: redirect_path || referrer_path || users_path
  end

  def destroy_all
    @users = User.kept.strict_loading
    @users = filter_collection(@users)
    @users.quickly_discard_all

    respond_with @users,
      flash: true,
      actions: FlashAction::Cancel.new(params),
      location: redirect_path || users_path
  end

  def undiscard_all
    @users = User.discarded.strict_loading
    @users = filter_collection(@users)
    @users.quickly_undiscard_all

    respond_with @users,
      flash: true,
      location: redirect_path || referrer_path || users_path
  end

  private

  def user_params
    params
      .fetch(:user, {})
      .then { |input| UserParamsParser.new(input).parse }
      .permit(
        :organization_type, :organization_id,
        :first_name, :last_name, :email,
        :organization_admin, :super_admin,
        office_ids: []
      )
  end
end
