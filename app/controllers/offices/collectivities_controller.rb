# frozen_string_literal: true

module Offices
  class CollectivitiesController < ::CollectivitiesController
    private

    def build_collectivities_scope
      office = Office.find(params[:office_id])

      authorize! office, to: :show?
      only_kept! office
      only_kept! office.ddfip

      @parent = office
      @collectivities = office.on_territory_collectivities
    end
  end
end
