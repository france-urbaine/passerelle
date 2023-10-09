# frozen_string_literal: true

module API
  class CollectivitiesController < ApplicationController
    before_action :authorize!

    def index
      @collectivities = build_and_authorize_scope
      @collectivities, @pagy = index_collection(@collectivities)

      respond_with @collectivities
    end

    private

    def build_and_authorize_scope
      authorized(Collectivity.all).strict_loading
    end
  end
end
