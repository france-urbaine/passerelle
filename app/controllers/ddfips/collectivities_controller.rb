# frozen_string_literal: true

module DDFIPs
  class CollectivitiesController < ::CollectivitiesController
    before_action do
      ddfip = DDFIP.find(params[:ddfip_id])

      next gone(ddfip) if ddfip&.discarded?

      @parent = ddfip
      @collectivities_scope = ddfip.on_territory_collectivities
    end
  end
end
