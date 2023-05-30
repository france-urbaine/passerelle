# frozen_string_literal: true

module DDFIPs
  class CollectivitiesController < ::CollectivitiesController
    private

    def build_collectivities_scope
      ddfip = DDFIP.find(params[:ddfip_id])

      authorize! ddfip, to: :show?
      only_kept! ddfip

      @parent = ddfip
      @collectivities = ddfip.on_territory_collectivities
    end
  end
end
