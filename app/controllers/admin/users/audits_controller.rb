# frozen_string_literal: true

module Admin
  module Users
    class AuditsController < Admin::AuditsController
      protected

      def load_and_authorize_resource
        if @user.nil?
          @user = User.find(params[:user_id])
          authorize! @user
        end
        @user
      end
    end
  end
end
