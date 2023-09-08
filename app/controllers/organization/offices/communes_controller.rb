# frozen_string_literal: true

module Organization
  module Offices
    class CommunesController < ApplicationController
      before_action :authorize!
      before_action :load_and_authorize_office
      before_action :autocompletion_not_implemented!, only: :index
      before_action :better_view_on_office, only: :index

      def index
        @communes = authorize_communes_scope
        @communes, @pagy = index_collection(@communes, nested: true)
      end

      def remove
        @commune = find_and_authorize_commune
        @referrer_path = referrer_path || organization_office_path(@office)
      end

      def destroy
        @commune = find_and_authorize_commune
        @office.communes.destroy(@commune)

        respond_with @commune,
          flash: true,
          location: redirect_path || organization_office_path(@office)
      end

      def edit_all
        @referrer_path = referrer_path || organization_office_path(@office)
      end

      def update_all
        office_params = params
          .fetch(:office, {})
          .slice(:commune_ids)
          .permit(commune_ids: [])

        service = ::Offices::UpdateService.new(@office, office_params)
        service.save

        respond_with service,
          flash: true,
          location: -> { redirect_path || organization_office_path(@office) }
      end

      def remove_all
        @communes = authorize_communes_scope
        @communes = filter_collection(@communes)
        @referrer_path = referrer_path || organization_office_path(@office)
      end

      def destroy_all
        @communes = authorize_communes_scope
        @communes = filter_collection(@communes)
        @office.communes.destroy(@communes)

        respond_with @communes,
          flash: true,
          location: redirect_path || organization_office_path(@office)
      end

      private

      def load_and_authorize_office
        @office = current_organization.offices.find(params[:office_id])

        authorize! @office, to: :show?
        only_kept! @office.ddfip, @office
      end

      def better_view_on_office
        return if turbo_frame_request?
        return if params.key?(:debug)

        redirect_to organization_office_path(@office), status: :see_other
      end

      def authorize_communes_scope
        authorized(@office.communes).strict_loading
      end

      def find_and_authorize_commune
        commune = @office.departement_communes.find(params[:id])
        authorize! commune
        commune
      end
    end
  end
end
