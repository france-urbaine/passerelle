# frozen_string_literal: true

class UserServicesController < ApplicationController
  respond_to :html

  def index
    @services = Service.kept.strict_loading
    @services = @services.where(ddfip_id: params[:ddfip_id]) if params[:ddfip_id]

    @user   = User.find(params[:user_id]) if params[:user_id]
    @user ||= User.new
  end
end
