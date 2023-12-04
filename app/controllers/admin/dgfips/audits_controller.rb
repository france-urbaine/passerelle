# frozen_string_literal: true

module Admin
  module DGFIPs
    class AuditsController < Admin::AuditsController
      protected

      def load_and_authorize_resource
        if @dgfip.nil?
          @dgfip = DGFIP.find_or_create_singleton_record
          authorize! @dgfip
        end
        @dgfip
      end
    end
  end
end
