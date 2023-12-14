# frozen_string_literal: true

module Admin
  module DDFIPs
    class AuditsController < ApplicationController
      before_action :authorize!

      def index
        @audits, @pagy = load_audits_collection(
          load_and_authorize_ddfip.audits.descending
        )
      end

      protected

      def load_and_authorize_ddfip
        @ddfip = DDFIP.find(params[:ddfip_id])

        authorize! @ddfip, to: :show?

        @ddfip
      end
    end
  end
end
