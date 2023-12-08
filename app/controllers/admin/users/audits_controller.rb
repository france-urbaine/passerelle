# frozen_string_literal: true

module Admin
  module Users
    class AuditsController < ApplicationController
      before_action :authorize!

      def index
        @audits, @pagy = load_audits_collection(
          load_and_authorize_user.audits.descending
        )
      end

      protected

      def load_and_authorize_user
        @user = User.find(params[:user_id])

        authorize! @user, to: :show?

        @user
      end
    end
  end
end
