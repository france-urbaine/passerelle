# frozen_string_literal: true

module DDFIPs
  class CollectivitiesController < ::CollectivitiesController
    private

    def load_and_authorize_parent
      ddfip = DDFIP.find(params[:ddfip_id])

      authorize! ddfip, to: :show?
      only_kept! ddfip

      @parent = ddfip
    end

    def build_and_authorize_scope(as: :default)
      authorized(@parent.on_territory_collectivities, as:).strict_loading
    end
  end
end
