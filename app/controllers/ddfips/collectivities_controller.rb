# frozen_string_literal: true

module DDFIPs
  class CollectivitiesController < ::CollectivitiesController
    private

    def scope_collectivities
      ddfip = DDFIP.find(params[:ddfip_id])

      only_kept! ddfip

      @parent = ddfip
      @collectivities = ddfip.on_territory_collectivities
    end
  end
end
