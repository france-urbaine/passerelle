# frozen_string_literal: true

module Admin
  module DDFIPs
    class AuditsController < Admin::AuditsController
      protected

      def load_and_authorize_resource
        if @ddfip.nil?
          @ddfip = DDFIP.find(params[:ddfip_id])
          authorize! @ddfip
        end
        @ddfip
      end
    end
  end
end
