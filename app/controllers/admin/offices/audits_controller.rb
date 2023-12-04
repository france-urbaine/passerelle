# frozen_string_literal: true

module Admin
  module Offices
    class AuditsController < Admin::AuditsController
      protected

      def load_and_authorize_resource
        if @office.nil?
          @office = Office.find(params[:office_id])
          authorize! @office
        end
        @office
      end
    end
  end
end
