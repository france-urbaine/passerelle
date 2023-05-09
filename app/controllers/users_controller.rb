# frozen_string_literal: true

class UsersController < ApplicationController
  respond_to :html

  before_action do
    @parent =
      if    params.include?(:publisher_id)    then Publisher.find(params[:publisher_id])
      elsif params.include?(:collectivity_id) then Collectivity.find(params[:collectivity_id])
      elsif params.include?(:ddfip_id)        then DDFIP.find(params[:ddfip_id])
      end

    next gone(@parent) if @parent&.discarded?

    @user_scope = @parent&.users || User.all
  end

  def index
    return not_implemented if autocomplete_request?
    return redirect_to(@parent, status: :see_other) if @parent && !turbo_frame_request?

    @users = @user_scope.kept.strict_loading
    @users, @pagy = index_collection(@users, nested: @parent)
  end

  def show
    @user = @user_scope.find(params[:id])
    gone(@user) if @user.discarded?
  end

  def new
    @user = @user_scope.build
    @background_url = referrer_path || parent_path || users_path
  end

  def edit
    @user = @user_scope.find(params[:id])
    return gone(@user) if @user.discarded?

    @background_url = referrer_path || user_path(@user)
  end

  def remove
    @user = @user_scope.find(params[:id])
    return gone(@user) if @user.discarded?

    @background_url = referrer_path || user_path(@user)
  end

  def remove_all
    @users = @user_scope.kept.strict_loading
    @users = filter_collection(@users)
    @background_url = referrer_path || users_path(**selection_params)
  end

  def create
    @user = @user_scope.build(user_params)
    @user.invite(by: current_user)
    @user.save

    respond_with @user,
      flash: true,
      location: -> { redirect_path || parent_path || users_path }
  end

  def update
    @user = @user_scope.find(params[:id])
    return gone(@user) if @user.discarded?

    @user.update(user_params)

    respond_with @user,
      flash: true,
      location: -> { redirect_path || users_path }
  end

  def destroy
    @user = @user_scope.find(params[:id])
    @user.discard

    respond_with @user,
      flash: true,
      actions: FlashAction::Cancel.new(params),
      location: redirect_path || users_path
  end

  def undiscard
    @user = @user_scope.find(params[:id])
    @user.undiscard

    respond_with @user,
      flash: true,
      location: redirect_path || referrer_path || users_path
  end

  def destroy_all
    @users = @user_scope.kept.strict_loading
    @users = filter_collection(@users)
    @users.quickly_discard_all

    respond_with @users,
      flash: true,
      actions: FlashAction::Cancel.new(params),
      location: redirect_path || parent_path || users_path
  end

  def undiscard_all
    @users = @user_scope.discarded.strict_loading
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
