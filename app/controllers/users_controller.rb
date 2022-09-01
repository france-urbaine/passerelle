# frozen_string_literal: true

class UsersController < ApplicationController
  respond_to :html
  before_action :set_user, only: %i[show edit update destroy]

  def index
    @users = User.strict_loading
    @users = search(@users)
    @users = order(@users)
    @pagy, @users = pagy(@users)
  end

  def new
    @user = User.new
  end

  def show; end
  def edit; end

  def create
    @user = User.new(user_params)
    @user.invite(from: current_user)

    if @user.save
      @notice   = t(".success")
      @location = params.fetch(:form_back, users_path)

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @location, notice: @notice }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @user.update(user_params)
      @notice   = t(".success")
      @location = params.fetch(:form_back, users_path)

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @location, notice: @notice }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy

    @notice   = t(".success")
    @location = params.fetch(:form_back, users_path)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @location, notice: @notice }
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    input             = params.fetch(:user, {})
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
        when "Publisher"    then Publisher   .kept.search(name: organization_name).pick(:id)
        when "DDFIP"        then DDFIP       .kept.search(name: organization_name).pick(:id)
        when "Collectivity" then Collectivity.kept.search(name: organization_name).pick(:id)
        end
    end

    input.permit(
      :organization_type, :organization_id,
      :first_name, :last_name, :email,
      :organization_admin, :super_admin
    )
  end
end
