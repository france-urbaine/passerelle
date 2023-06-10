# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authorize!
  before_action :load_and_authorize_parent
  before_action :autocompletion_not_implemented!, only: :index
  before_action :better_view_on_parent, only: :index

  def index
    @users = build_and_authorize_scope
    @users, @pagy = index_collection(@users, nested: @parent)
  end

  def show
    @user = find_and_authorize_user
  end

  def new
    @user = build_user
    @background_url = referrer_path || parent_path || users_path
  end

  def create
    @user = build_user(user_params)
    @user.invite(by: current_user)
    @user.save

    respond_with @user,
      flash: true,
      location: -> { redirect_path || parent_path || users_path }
  end

  def edit
    @user = find_and_authorize_user
    @background_url = referrer_path || user_path(@user)
  end

  def update
    @user = find_and_authorize_user
    @user.update(user_params)

    respond_with @user,
      flash: true,
      location: -> { redirect_path || users_path }
  end

  def remove
    @user = find_and_authorize_user
    @background_url = referrer_path || user_path(@user)
  end

  def destroy
    @user = find_and_authorize_user(allow_discarded: true)
    @user.discard

    respond_with @user,
      flash: true,
      actions: FlashAction::Cancel.new(params),
      location: redirect_path || users_path
  end

  def undiscard
    @user = find_and_authorize_user(allow_discarded: true)
    @user.undiscard

    respond_with @user,
      flash: true,
      location: redirect_path || referrer_path || users_path
  end

  def remove_all
    @users = build_and_authorize_scope
    @users = filter_collection(@users)
    @background_url = referrer_path || users_path(**selection_params)
  end

  def destroy_all
    @users = build_and_authorize_scope(as: :destroyable)
    @users = filter_collection(@users)
    @users.quickly_discard_all

    respond_with @users,
      flash: true,
      actions: FlashAction::Cancel.new(params),
      location: redirect_path || parent_path || users_path
  end

  def undiscard_all
    @users = build_and_authorize_scope(as: :undiscardable)
    @users = filter_collection(@users)
    @users.quickly_undiscard_all

    respond_with @users,
      flash: true,
      location: redirect_path || referrer_path || parent_path || users_path
  end

  private

  def load_and_authorize_parent
    # Override this method to load a @parent variable
  end

  def build_and_authorize_scope(as: :default)
    authorized(User.all, as:).strict_loading
  end

  def build_user(...)
    build_and_authorize_scope.build(...)
  end

  def find_and_authorize_user(allow_discarded: false)
    user = User.find(params[:id])

    authorize! user
    only_kept! user unless allow_discarded

    user
  end

  def user_params
    authorized(params.fetch(:user, {}))
      .then { |input| UserParamsParser.new(input, @parent).parse }
  end

  def parent_path
    url_for(@parent) if @parent
  end
end
