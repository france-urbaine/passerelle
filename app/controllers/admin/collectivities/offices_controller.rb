# frozen_string_literal: true

module Admin
  module Collectivities
    class OfficesController < ApplicationController
      before_action :authorize!
      before_action :load_and_authorize_collectivity
      before_action :autocompletion_not_implemented!, only: :index
      before_action :better_view_on_collectivity, only: :index

      def index
        @offices = authorize_offices_scope
        @offices, @pagy = index_collection(@offices, nested: true)
      end

      private

      def load_and_authorize_collectivity
        @collectivity = Collectivity.find(params[:collectivity_id])

        authorize! @collectivity, to: :show?
        only_kept! @collectivity
      end

      def better_view_on_collectivity
        return if turbo_frame_request?
        return if params.key?(:debug)

        redirect_to admin_collectivity_path(@collectivity), status: :see_other
      end

      def authorize_offices_scope
        authorized(@collectivity.assigned_offices).strict_loading
      end
    end
  end
end
