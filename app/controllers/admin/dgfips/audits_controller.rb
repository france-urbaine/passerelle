# frozen_string_literal: true

module Admin
  module DGFIPs
    class AuditsController < ApplicationController
      before_action :authorize!

      def index
        @audits, @pagy = load_audits_collection(
          load_and_authorize_dgfip.audits.descending
        )
      end

      protected

      def load_and_authorize_dgfip
        @dgfip = DGFIP.find_or_create_singleton_record

        authorize! @dgfip, to: :show?

        @dgfip
      end
    end
  end
end
