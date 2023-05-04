# frozen_string_literal: true

class OfficeUsersController < ApplicationController
  respond_to :html

  def edit
    @office            = Office.find(params[:office_id])
    @office_users_form = OfficeUsersForm.new(@office)
    @background_url    = referrer_path || office_path(@office)
  end

  def remove
    @office         = Office.find(params[:office_id])
    @user           = @office.users.find(params[:id])
    @background_url = referrer_path || office_path(@office)
  end

  def update
    @office               = Office.find(params[:office_id])
    @office_users_updater = OfficeUsersUpdater.new(@office)
    @office_users_updater.update(user_ids_params)

    respond_with @office_users_updater,
      flash: true,
      location: -> { redirect_path || office_path(@office) }
  end

  def destroy
    @office = Office.find(params[:office_id])
    @user   = @office.users.find(params[:id])
    @office.users.destroy(@user)

    respond_with @office,
      flash: true,
      location: redirect_path || office_path(@office)
  end

  private

  def user_ids_params
    params
      .fetch(:office_users, {})
      .slice(:user_ids)
      .permit(user_ids: [])
      .fetch(:user_ids, [])
  end
end
