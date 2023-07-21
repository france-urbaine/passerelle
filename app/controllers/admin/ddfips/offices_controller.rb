# frozen_string_literal: true

module Admin
  module DDFIPs
    class OfficesController < ApplicationController
      before_action :authorize!
      before_action :load_and_authorize_ddfip
      before_action :autocompletion_not_implemented!, only: :index
      before_action :better_view_on_ddfip, only: :index

      def index
        @offices = authorize_offices_scope
        @offices, @pagy = index_collection(@offices, nested: true)
      end

      def new
        @office = build_office
        @referrer_path = referrer_path || admin_ddfip_path(@ddfip)
      end

      def create
        @office = build_office
        service = ::Offices::CreateService.new(@office, office_params, ddfip: @ddfip)
        result  = service.save

        respond_with result,
          flash: true,
          location: -> { redirect_path || admin_ddfip_path(@ddfip) }
      end

      def remove_all
        @offices = authorize_offices_scope
        @offices = filter_collection(@offices)
        @referrer_path = referrer_path || admin_ddfip_path(@ddfip)
      end

      def destroy_all
        @offices = authorize_offices_scope(as: :destroyable)
        @offices = filter_collection(@offices)
        @offices.quickly_discard_all

        respond_with @offices,
          flash: true,
          actions: undiscard_all_admin_ddfip_offices_action(@ddfip),
          location: redirect_path || admin_ddfip_path(@ddfip)
      end

      def undiscard_all
        @offices = authorize_offices_scope(as: :undiscardable)
        @offices = filter_collection(@offices)
        @offices.quickly_undiscard_all

        respond_with @offices,
          flash: true,
          location: redirect_path || referrer_path || admin_ddfip_path(@ddfip)
      end

      private

      def load_and_authorize_ddfip
        @ddfip = DDFIP.find(params[:ddfip_id])

        authorize! @ddfip, to: :show?
        only_kept! @ddfip
      end

      def better_view_on_ddfip
        return if turbo_frame_request?
        return if params.key?(:debug)

        redirect_to admin_ddfip_path(@ddfip), status: :see_other
      end

      def authorize_offices_scope(as: :default)
        authorized(@ddfip.offices, as:).strict_loading
      end

      def build_office(...)
        authorize_offices_scope.build(...)
      end

      def office_params
        authorized(params.fetch(:office, {}))
      end
    end
  end
end
