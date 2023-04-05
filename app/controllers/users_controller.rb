# frozen_string_literal: true

class UsersController < ApplicationController
  respond_to :html

  before_action :set_user,                   only: %i[show edit update remove destroy undiscard]
  before_action :set_background_content_url, only: %i[new edit remove]

  def index
    @users = User.kept.strict_loading
    @users, @pagy = index_collection(@users)
  end

  def show; end

  def new
    @user = User.new(user_params)
  end

  def edit; end
  def remove; end

  def create
    @user = User.new(user_params)
    @user.invite(by: current_user)

    if @user.save
      @location = url_from(params[:redirect]) || users_path
      @notice   = translate(".success")

      respond_to do |format|
        format.turbo_stream { redirect_to @location, notice: @notice }
        format.html         { redirect_to @location, notice: @notice }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @user.update(user_params)
      @location = url_from(params[:redirect]) || users_path
      @notice   = translate(".success")

      respond_to do |format|
        format.turbo_stream { redirect_to @location, notice: @notice }
        format.html         { redirect_to @location, notice: @notice }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.discard
    DeleteDiscardedUsersJob.set(wait: 5.minutes).perform_later(@user.id)

    @location = url_from(params[:redirect]) || users_path
    @notice   = translate(".success")
    @cancel   = FlashAction::Cancel.new(params).to_session

    respond_to do |format|
      format.turbo_stream { redirect_to @location, notice: @notice, flash: { actions: @cancel } }
      format.html         { redirect_to @location, notice: @notice, flash: { actions: @cancel } }
    end
  end

  def remove_all
    @users = User.kept.strict_loading
    @users = filter_collection(@users)

    @background_content_url = users_path(ids: params[:ids], **index_params)
    @return_location        = users_path(**index_params)
  end

  def destroy_all
    @users = User.kept.strict_loading
    @users = filter_collection(@users)
    ids    = @users.ids

    @users.update_all(discarded_at: Time.current)
    DeleteDiscardedUsersJob.set(wait: 5.minutes).perform_later(*ids)

    @location   = users_path if params[:ids] == "all"
    @location ||= users_path(**index_params)
    @notice     = translate(".success")
    @cancel     = FlashAction::Cancel.new(params).to_session

    respond_to do |format|
      format.turbo_stream  { redirect_to @location, notice: @notice, flash: { actions: @cancel } }
      format.html          { redirect_to @location, notice: @notice, flash: { actions: @cancel } }
    end
  end

  def undiscard
    @user.undiscard

    @location = url_from(params[:redirect]) || users_path
    @notice   = translate(".success")

    respond_to do |format|
      format.turbo_stream { redirect_to @location, notice: @notice }
      format.html         { redirect_to @location, notice: @notice }
    end
  end

  def undiscard_all
    @users = User.discarded.strict_loading
    @users = filter_collection(@users)
    @users.update_all(discarded_at: nil)

    @location = url_from(params[:redirect]) || users_path
    @notice   = translate(".success")

    respond_to do |format|
      format.turbo_stream { redirect_to @location, notice: @notice }
      format.html         { redirect_to @location, notice: @notice }
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def set_background_content_url
    default = users_path
    default = user_path(@user) if @user&.persisted?

    @background_content_url = url_from(params[:content]) || default
  end

  def user_params
    input = params.fetch(:user, {})
    input = extract_organization_params(input)
    input = extract_service_ids_params(input)

    input.permit(
      :organization_type, :organization_id,
      :first_name, :last_name, :email,
      :organization_admin, :super_admin,
      service_ids: []
    )
  end

  def extract_organization_params(input)
    input.delete(:organization)

    organization_data = input.delete(:organization_data)
    organization_name = input.delete(:organization_name)

    if organization_data.present?
      organization_data         = JSON.parse(organization_data)
      input[:organization_type] = organization_data["type"]
      input[:organization_id]   = organization_data["id"]
    end

    if organization_name.present?
      input[:organization_id] =
        case input[:organization_type]
        when "Publisher"    then Publisher.kept.search(name: organization_name).pick(:id)
        when "DDFIP"        then DDFIP.kept.search(name: organization_name).pick(:id)
        when "Collectivity" then Collectivity.kept.search(name: organization_name).pick(:id)
        end
    end

    input
  end

  def extract_service_ids_params(input)
    service_ids = input.delete(:service_ids)

    if service_ids.present? && input[:organization_type] == "DDFIP"
      input[:service_ids] = Service.kept
        .where(id: service_ids)
        .where(ddfip_id: input[:organization_id])
        .pluck(:id)
    end

    input
  end

  def index_params
    params
      .slice(:search, :order, :page)
      .permit(:search, :order, :page)
  end
end
