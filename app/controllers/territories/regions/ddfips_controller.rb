# frozen_string_literal: true

module Territories
  module Regions
    class DDFIPsController < ApplicationController
      before_action :authorize!
      before_action :load_and_authorize_region
      before_action :autocompletion_not_implemented!, only: :index
      before_action :better_view_on_region, only: :index

      def index
        @ddfips = authorized(@region.ddfips).strict_loading
        @ddfips, @pagy = index_collection(@ddfips, nested: true)
      end

      private

      def load_and_authorize_region
        @region = Region.find(params[:region_id])

        authorize! @region, to: :show?
        only_kept! @region
      end

      def better_view_on_region
        return if turbo_frame_request?
        return if params.key?(:debug)

        redirect_to territories_region_path(@region), status: :see_other
      end
    end
  end
end
