# frozen_string_literal: true

module Admin
  module Users
    class AuditsController < ApplicationController
      def index
        authorize!(:index?, with: Admin::AuditPolicy)

        @user = User.find(params[:user_id])
        authorize! @user

        if turbo_frame_request?
          @audits, = index_collection(
            authorized_audits_scope,
            nested: true
          )
        else
          @pagy, @audits = pagy(authorized_audits_scope)
        end
      end

      protected

      def authorized_audits_scope
        authorized_scope(
          @user.audits.descending,
          with: Admin::AuditPolicy
        )
      end
    end
  end
end
