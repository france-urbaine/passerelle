# frozen_string_literal: true

module Admin
  class DGFIPsController < ApplicationController
    before_action :authorize!

    def index
      @dgfips = authorize_dgfips_scope
      @dgfips, @pagy = index_collection(@dgfips)

      respond_with @ddfips do |format|
        format.html.autocomplete { render layout: false }
      end
    end

    def show
      @dgfip = find_and_authorize_dgfip
    end

    def new
      @dgfip = build_dgfip
      @referrer_path = referrer_path || admin_dgfips_path
    end

    def create
      @dgfip = build_dgfip(dgfip_params)
      @dgfip.save

      respond_with @dgfip,
        flash: true,
        location: -> { redirect_path || admin_dgfips_path }
    end

    def edit
      @dgfip = find_and_authorize_dgfip
      @referrer_path = referrer_path || admin_dgfip_path(@dgfip)
    end

    def update
      @dgfip = find_and_authorize_dgfip
      @dgfip.update(dgfip_params)

      respond_with @dgfip,
        flash: true,
        location: -> { redirect_path || admin_dgfips_path }
    end

    def remove
      @dgfip = find_and_authorize_dgfip
      @referrer_path = referrer_path || admin_dgfip_path(@dgfip)
      @redirect_path = referrer_path unless referrer_path&.include?(admin_dgfip_path(@dgfip))
    end

    def destroy
      @dgfip = find_and_authorize_dgfip(allow_discarded: true)
      @dgfip.discard

      respond_with @dgfip,
        flash: true,
        actions: undiscard_admin_dgfip_action(@dgfip),
        location: redirect_path || admin_dgfips_path
    end

    def undiscard
      @dgfip = find_and_authorize_dgfip(allow_discarded: true)
      @dgfip.undiscard

      respond_with @dgfip,
        flash: true,
        location: redirect_path || referrer_path || admin_dgfips_path
    end

    def remove_all
      @dgfips = authorize_dgfips_scope
      @dgfips = filter_collection(@dgfips)
      @referrer_path = referrer_path || admin_dgfips_path(**selection_params)
    end

    def destroy_all
      @dgfips = authorize_dgfips_scope(as: :destroyable)
      @dgfips = filter_collection(@dgfips)
      @dgfips.quickly_discard_all

      respond_with @dgfips,
        flash: true,
        actions: undiscard_all_admin_dgfips_action,
        location: redirect_path || admin_dgfips_path
    end

    def undiscard_all
      @dgfips = authorize_dgfips_scope(as: :undiscardable)
      @dgfips = filter_collection(@dgfips)
      @dgfips.quickly_undiscard_all

      respond_with @dgfips,
        flash: true,
        location: redirect_path || referrer_path || admin_dgfips_path
    end

    private

    def authorize_dgfips_scope(as: :default)
      authorized(DGFIP.all, as:).strict_loading
    end

    def build_dgfip(...)
      authorize_dgfips_scope.build(...)
    end

    def find_and_authorize_dgfip(allow_discarded: false)
      dgfip = DGFIP.find(params[:id])

      authorize! dgfip
      only_kept! dgfip unless allow_discarded

      dgfip
    end

    def dgfip_params
      authorized(params.fetch(:dgfip, {}))
    end
  end
end
