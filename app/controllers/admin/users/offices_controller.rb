# frozen_string_literal: true

module Admin
  module Users
    class OfficesController < ApplicationController
      def index
        authorize!(:manage?, with: Admin::UserPolicy)
        authorize!(:index?, with: Admin::OfficePolicy)

        return not_acceptable unless turbo_frame_request?

        @ddfip = DDFIP.find(params.require(:ddfip_id))
        authorize! @ddfip, to: :manage?
        only_kept! @ddfip

        @offices = authorized(@ddfip.offices).strict_loading

        if params[:user_id]
          @user = User.find(params[:user_id])
          authorize! @user, to: :manage?
          only_kept! @user
        else
          @user = User.new(params.slice(:office_ids).permit!)
        end

        @office_users = @user.office_users
        @office_users += @offices.filter_map do |office|
          OfficeUser.new(user: @user, office: office) unless office.id.in?(@user.office_ids)
        end

        render layout: false
      end
    end
  end
end
