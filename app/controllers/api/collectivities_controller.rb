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

    def build_and_authorize_scope(as: :default)
      authorized(Collectivity.all, as:).strict_loading
    end
  end
end
