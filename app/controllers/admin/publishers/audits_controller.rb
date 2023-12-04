# frozen_string_literal: true

module Admin
  module Publishers
    class AuditsController < Admin::AuditsController
      protected

      def load_and_authorize_resource
        if @publisher.nil?
          @publisher = Publisher.find(params[:publisher_id])
          authorize! @publisher
        end
        @publisher
      end
    end
  end
end
