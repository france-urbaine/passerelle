# frozen_string_literal: true

module Organization
  module OauthApplications
    class AuditsController < ApplicationController
      def index
        authorize!(:index?, with: Organization::OauthApplications::AuditPolicy)
        load_and_authorize_resource
        load_audits
      end

      protected

      def authorized_audits_scope
        authorized_scope(
          load_and_authorize_resource.own_and_associated_audits.order(created_at: :desc),
          with: Organization::OauthApplications::AuditPolicy
        )
      end

      def load_and_authorize_resource
        if @oauth_application.nil?
          scope =
            case current_organization
            when Publisher then current_organization.oauth_applications.with_discarded
            else OauthApplication.none
            end

          @oauth_application = scope.find(params[:oauth_application_id])
          authorize! @oauth_application
        end
        @oauth_application
      end

      def load_audits
        if turbo_frame_request_id == "audits"
          @audits, @pagy = index_collection(authorized_audits_scope, nested: true)
        else
          @audits, @pagy = index_collection(authorized_audits_scope, items: 100)
        end
      end
    end
  end
end
