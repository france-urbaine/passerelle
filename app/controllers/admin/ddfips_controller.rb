# frozen_string_literal: true

module Admin
  class DDFIPsController < ApplicationController
    before_action :authorize!

    def index
      @ddfips = authorize_ddfips_scope
      @ddfips, @pagy = index_collection(@ddfips)

      respond_with @ddfips do |format|
        format.html.autocomplete { render layout: false }
        format.html.any do
          @ddfips = @ddfips.preload(departement: :region)
        end
      end
    end

    def show
      @ddfip = find_and_authorize_ddfip
    end

    def new
      @ddfip = build_ddfip
      @referrer_path = referrer_path || admin_ddfips_path
    end

    def create
      @ddfip = build_ddfip(ddfip_params)
      @ddfip.save

      respond_with @ddfip,
        flash: true,
        location: -> { redirect_path || admin_ddfips_path }
    end

    def edit
      @ddfip = find_and_authorize_ddfip
      @referrer_path = referrer_path || admin_ddfip_path(@ddfip)
    end

    def update
      @ddfip = find_and_authorize_ddfip
      @ddfip.update(ddfip_params)

      respond_with @ddfip,
        flash: true,
        location: -> { redirect_path || admin_ddfips_path }
    end

    def remove
      @ddfip = find_and_authorize_ddfip
      @referrer_path = referrer_path || admin_ddfip_path(@ddfip)
      @redirect_path = referrer_path unless referrer_path&.include?(admin_ddfip_path(@ddfip))
    end

    def destroy
      @ddfip = find_and_authorize_ddfip(allow_discarded: true)
      @ddfip.discard

      respond_with @ddfip,
        flash: true,
        actions: undiscard_admin_ddfip_action(@ddfip),
        location: redirect_path || admin_ddfips_path
    end

    def undiscard
      @ddfip = find_and_authorize_ddfip(allow_discarded: true)
      @ddfip.undiscard

      respond_with @ddfip,
        flash: true,
        location: redirect_path || referrer_path || admin_ddfips_path
    end

    def remove_all
      @ddfips = authorize_ddfips_scope
      @ddfips = filter_collection(@ddfips)
      @referrer_path = referrer_path || admin_ddfips_path(**selection_params)
    end

    def destroy_all
      @ddfips = authorize_ddfips_scope(as: :destroyable)
      @ddfips = filter_collection(@ddfips)
      @ddfips.quickly_discard_all

      respond_with @ddfips,
        flash: true,
        actions: undiscard_all_admin_ddfips_action,
        location: redirect_path || admin_ddfips_path
    end

    def undiscard_all
      @ddfips = authorize_ddfips_scope(as: :undiscardable)
      @ddfips = filter_collection(@ddfips)
      @ddfips.quickly_undiscard_all

      respond_with @ddfips,
        flash: true,
        location: redirect_path || referrer_path || admin_ddfips_path
    end

    private

    def authorize_ddfips_scope(as: :default)
      authorized(DDFIP.all, as:).strict_loading
    end

    def build_ddfip(...)
      authorize_ddfips_scope.build(...)
    end

    def find_and_authorize_ddfip(allow_discarded: false)
      ddfip = DDFIP.find(params[:id])

      authorize! ddfip
      only_kept! ddfip unless allow_discarded

      ddfip
    end

    def ddfip_params
      authorized(params.fetch(:ddfip, {}))
    end
  end
end
