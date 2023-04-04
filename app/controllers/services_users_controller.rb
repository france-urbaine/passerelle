# frozen_string_literal: true

class ServicesUsersController < ApplicationController
  respond_to :html
  before_action :set_service

  def edit
    @ddfip_users            = ddfip_users
    @background_content_url = url_from(params[:content]) || service_path(@service)
  end

  def update
    if @service.update(service_params)
      @location = url_from(params[:redirect]) || service_path(@service)
      @notice   = translate(".success")

      respond_to do |format|
        format.turbo_stream { redirect_to @location, notice: @notice }
        format.html         { redirect_to @location, notice: @notice }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_service
    @service = Service.find(params[:service_id])
  end

  def ddfip_users
    @service.ddfip.users.kept
  end

  def service_params
    input    = params.fetch(:service, {})
    user_ids = extract_user_ids(input)

    { user_ids: user_ids }
  end

  def extract_user_ids(input)
    users_ids = input.delete(:users_ids)
    ddfip_users.where(id: users_ids).pluck(:id)
  end
end
