# frozen_string_literal: true

module Users
  class OfficesController < ApplicationController
    def index
      return not_acceptable unless turbo_frame_request?

      @ddfip   = DDFIP.kept.find(params.require(:ddfip_id))
      @offices = @ddfip.offices.kept.strict_loading

      @user = User.new(params.slice(:office_ids).permit!)
      @user = User.find(params[:user_id]) if params[:user_id]

      render layout: false
    end
  end
end
