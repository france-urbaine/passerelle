# frozen_string_literal: true

module Admin
  module Collectivities
    class AuditsController < ApplicationController
      before_action :authorize!

      def index
        @audits, @pagy = load_audits_collection(
          load_and_authorize_collectivity.audits.descending
        )
      end

      protected

      def load_and_authorize_collectivity
        @collectivity = Collectivity.find(params[:collectivity_id])

        authorize! @collectivity, to: :show?

        @collectivity
      end
    end
  end
end
