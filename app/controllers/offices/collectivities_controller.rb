# frozen_string_literal: true

module Offices
  class CollectivitiesController < ::CollectivitiesController
    private

    def load_and_authorize_parent
      office = Office.find(params[:office_id])

      authorize! office, to: :show?
      only_kept! office
      only_kept! office.ddfip

      @parent = office
    end

    def build_and_authorize_scope(as: :default)
      authorized(@parent.on_territory_collectivities, as:).strict_loading
    end
  end
end
