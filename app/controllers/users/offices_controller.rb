# frozen_string_literal: true

module Users
  class OfficesController < ApplicationController
    before_action :authorize!

    def index
      return not_acceptable unless turbo_frame_request?

      ddfip = current_user.organization
      ddfip = DDFIP.kept.find(params.require(:ddfip_id)) if allowed_to?(:switch_ddfip?)

      @offices = ddfip.offices.kept.strict_loading

      if params[:user_id]
        @user = User.find(params[:user_id])
        authorize! @user
      else
        @user = User.new(params.slice(:office_ids).permit!)
      end

      render layout: false
    end
  end
end
