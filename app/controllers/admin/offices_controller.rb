# frozen_string_literal: true

module Admin
  class OfficesController < ApplicationController
    before_action :authorize!
    before_action :autocompletion_not_implemented!, only: :index

    def index
      @offices = authorize_offices_scope
      @offices, @pagy = index_collection(@offices)
    end

    def show
      @office = find_and_authorize_office
    end

    def new
      @office = build_office
      @referrer_path = referrer_path || admin_offices_path
    end

    def create
      @office = build_office
      service = ::Offices::CreateService.new(@office, office_params)
      result  = service.save

      respond_with result,
        flash: true,
        location: -> { redirect_path || admin_offices_path }
    end

    def edit
      @office = find_and_authorize_office
      @referrer_path = referrer_path || admin_office_path(@office)
    end

    def update
      @office = find_and_authorize_office
      service = ::Offices::UpdateService.new(@office, office_params)
      result  = service.save

      respond_with result,
        flash: true,
        location: -> { redirect_path || admin_offices_path }
    end

    def remove
      @office = find_and_authorize_office
      @referrer_path = referrer_path || admin_office_path(@office)
      @redirect_path = referrer_path unless referrer_path&.include?(admin_office_path(@office))
    end

    def destroy
      @office = find_and_authorize_office(allow_discarded: true)
      @office.discard

      respond_with @office,
        flash: true,
        actions: undiscard_admin_office_action(@office),
        location: redirect_path || admin_offices_path
    end

    def undiscard
      @office = find_and_authorize_office(allow_discarded: true)
      @office.undiscard

      respond_with @office,
        flash: true,
        location: redirect_path || referrer_path || admin_offices_path
    end

    def remove_all
      @offices = authorize_offices_scope
      @offices = filter_collection(@offices)
      @referrer_path = referrer_path || admin_offices_path(**selection_params)
    end

    def destroy_all
      @offices = authorize_offices_scope(as: :destroyable)
      @offices = filter_collection(@offices)
      @offices.quickly_discard_all

      respond_with @offices,
        flash: true,
        actions: undiscard_all_admin_offices_action,
        location: redirect_path || admin_offices_path
    end

    def undiscard_all
      @offices = authorize_offices_scope(as: :undiscardable)
      @offices = filter_collection(@offices)
      @offices.quickly_undiscard_all

      respond_with @offices,
        flash: true,
        location: redirect_path || referrer_path || admin_offices_path
    end

    private

    def authorize_offices_scope(as: :default)
      authorized(Office.all, as:).strict_loading
    end

    def build_office(...)
      authorize_offices_scope.build(...)
    end

    def find_and_authorize_office(allow_discarded: false)
      office = Office.find(params[:id])

      authorize! office
      only_kept! office.ddfip, office unless allow_discarded

      office
    end

    def office_params
      authorized(params.fetch(:office, {}))
    end
  end
end
