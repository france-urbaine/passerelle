# frozen_string_literal: true

module Offices
  class CollectivitiesController < ::CollectivitiesController
    before_action do
      office = Office.find(params[:office_id])

      next gone(office) if office.discarded?
      next gone(office.ddfip) if office.ddfip.discarded?

      @parent = office
      @collectivities_scope = office.on_territory_collectivities
    end
  end
end
