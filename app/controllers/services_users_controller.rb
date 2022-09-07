# frozen_string_literal: true

class ServicesUsersController < ApplicationController
  respond_to :html

  before_action :set_service

  def edit
    @ddfip_users      = @service.ddfip.users.kept
    @content_location = safe_location_param(:content, service_path(@service))
  end

  def update
    if @service.update(service_params)
      @location = safe_location_param(:redirect, service_path(@service))
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

  def service_params
    input = params.fetch(:service, {})
    input = extract_user_ids_params(input)

    input.permit(user_ids: [])
  end

  def extract_user_ids_params(input)
    users_ids = input.delete(:users_ids)

    input[:users_ids] = User.kept
                            .where(id: users_ids)
                            .where(organization: @service.ddfip)
                            .pluck(:id)

    input
  end
end
