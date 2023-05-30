# frozen_string_literal: true

module Publishers
  class CollectivitiesController < ::CollectivitiesController
    private

    def build_collectivities_scope
      publisher = Publisher.find(params[:publisher_id])

      authorize! publisher, to: :show?
      only_kept! publisher

      @parent = publisher
      @collectivities = publisher.collectivities
    end
  end
end
