# frozen_string_literal: true

module Publishers
  class CollectivitiesController < ::CollectivitiesController
    before_action do
      publisher = Publisher.find(params[:publisher_id])

      next gone(publisher) if publisher.discarded?

      @parent = publisher
      @collectivities_scope = publisher.collectivities
    end
  end
end
