# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authorize!
  before_action :build_users_scope
  before_action :authorize_users_scope
  before_action :build_user,     only: %i[new create]
  before_action :find_user,      only: %i[show edit remove update destroy undiscard]
  before_action :authorize_user, only: %i[show edit remove update destroy undiscard]

  def index
    return not_implemented if autocomplete_request?
    return redirect_to(@parent, status: :see_other) if @parent && !turbo_frame_request?

    @users = @users.kept.strict_loading
    @users, @pagy = index_collection(@users, nested: @parent)
  end

  def show
    only_kept! @user
  end

  def new
    @background_url = referrer_path || parent_path || users_path
  end

  def create
    @user.assign_attributes(user_params)
    @user.invite(by: current_user)
    @user.save

    respond_with @user,
      flash: true,
      location: -> { redirect_path || parent_path || users_path }
  end

  def edit
    only_kept! @user
    @background_url = referrer_path || user_path(@user)
  end

  def update
    only_kept! @user
    @user.update(user_params)

    respond_with @user,
      flash: true,
      location: -> { redirect_path || users_path }
  end

  def remove
    only_kept! @user
    @background_url = referrer_path || user_path(@user)
  end

  def destroy
    @user.discard

    respond_with @user,
      flash: true,
      actions: FlashAction::Cancel.new(params),
      location: redirect_path || users_path
  end

  def undiscard
    @user.undiscard

    respond_with @user,
      flash: true,
      location: redirect_path || referrer_path || users_path
  end

  def remove_all
    @users = @users.kept.strict_loading
    @users = filter_collection(@users)

    @background_url = referrer_path || users_path(**selection_params)
  end

  def destroy_all
    @users = @users.kept.strict_loading
    @users = filter_collection(@users)

    # Do not let the current user deleting himself
    @users = @users.where.not(id: current_user.id)
    @users.quickly_discard_all

    respond_with @users,
      flash: true,
      actions: FlashAction::Cancel.new(params),
      location: redirect_path || parent_path || users_path
  end

  def undiscard_all
    @users = @users.discarded.strict_loading
    @users = filter_collection(@users)
    @users.quickly_undiscard_all

    respond_with @users,
      flash: true,
      location: redirect_path || referrer_path || parent_path || users_path
  end

  private

  def build_users_scope
    @users = User.all
  end

  def authorize_users_scope
    @users = authorized(@users)
  end

  def build_user
    @user = @users.build
  end

  def find_user
    @user = User.find(params[:id])
  end

  def authorize_user
    authorize! @user
  end

  def user_params
    authorized(params.fetch(:user, {}))
      .then { |input| UserParamsParser.new(input, @parent).parse }
  end

  def parent_path
    url_for(@parent) if @parent
  end
end
