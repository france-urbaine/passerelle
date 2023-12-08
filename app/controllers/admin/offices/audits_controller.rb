# frozen_string_literal: true

module Admin
  module Offices
    class AuditsController < ApplicationController
      before_action :authorize!

      def index
        @audits, @pagy = load_audits_collection(
          load_and_authorize_office.audits.descending
        )
      end

      protected

      def load_and_authorize_office
        @office = Office.find(params[:office_id])

        authorize! @office, to: :show?

        @office
      end
    end
  end
end
