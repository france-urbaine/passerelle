# frozen_string_literal: true

module Admin
  class DGFIPsController < ApplicationController
    before_action :authorize!

    def show
      @dgfip = find_and_authorize_dgfip
    end

    def new
      @dgfip = build_dgfip
      @referrer_path = referrer_path || admin_dgfip_path
    end

    def create
      @dgfip = build_dgfip(dgfip_params)
      @dgfip.save

      respond_with @dgfip,
        flash: true,
        location: -> { redirect_path || admin_dgfip_path }
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
        location: -> { redirect_path || admin_dgfip_path }
    end

    private

    def authorize_dgfips_scope(as: :default)
      authorized(DGFIP.all, as:).strict_loading
    end

    def build_dgfip(...)
      authorize_dgfips_scope.build(...)
    end

    def find_and_authorize_dgfip
      dgfip = DGFIP.kept.first || DGFIP.find(nil)

      authorize! dgfip

      dgfip
    end

    def dgfip_params
      authorized(params.fetch(:dgfip, {}))
    end
  end
end
