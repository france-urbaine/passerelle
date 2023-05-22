# frozen_string_literal: true

module Offices
  class CollectivitiesController < ::CollectivitiesController
    private

    def scope_collectivities
      office = Office.find(params[:office_id])

      only_kept! office
      only_kept! office.ddfip

      @parent = office
      @collectivities = office.on_territory_collectivities
    end
  end
end
