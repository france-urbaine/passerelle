# frozen_string_literal: true

module Admin
  module Collectivities
    class AuditsController < Admin::AuditsController
      protected

      def load_and_authorize_resource
        if @collectivity.nil?
          @collectivity = Collectivity.find(params[:collectivity_id])
          authorize! @collectivity
        end
        @collectivity
      end
    end
  end
end
