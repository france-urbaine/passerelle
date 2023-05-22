# frozen_string_literal: true

module Publishers
  class CollectivitiesController < ::CollectivitiesController
    private

    def scope_collectivities
      publisher = Publisher.find(params[:publisher_id])

      only_kept! publisher

      @parent = publisher
      @collectivities = publisher.collectivities
    end

    def collectivity_params
      super().except(:publisher_id)
    end
  end
end
