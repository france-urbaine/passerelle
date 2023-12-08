# frozen_string_literal: true

module Organization
  module OauthApplications
    class AuditsController < ApplicationController
      before_action :authorize!

      def index
        @audits, @pagy = load_audits_collection(
          load_and_authorize_oauth_application
            .own_and_associated_audits
            .order(created_at: :desc)
        )
      end

      protected

      def load_and_authorize_oauth_application
        @oauth_application = current_organization
          .oauth_applications
          .with_discarded
          .find(params[:oauth_application_id])

        authorize! @oauth_application, to: :show?

        @oauth_application
      end
    end
  end
end
