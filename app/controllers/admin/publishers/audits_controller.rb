# frozen_string_literal: true

module Admin
  module Publishers
    class AuditsController < ApplicationController
      before_action :authorize!

      def index
        @audits, @pagy = load_audits_collection(
          load_and_authorize_publisher.audits.descending
        )
      end

      protected

      def load_and_authorize_publisher
        @publisher = Publisher.find(params[:publisher_id])

        authorize! @publisher, to: :show?

        @publisher
      end
    end
  end
end
