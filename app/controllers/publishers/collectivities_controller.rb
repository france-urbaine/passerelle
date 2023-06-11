# frozen_string_literal: true

module Publishers
  class CollectivitiesController < ::CollectivitiesController
    private

    def load_and_authorize_parent
      publisher = Publisher.find(params[:publisher_id])

      authorize! publisher, to: :show?
      only_kept! publisher

      @parent = publisher
    end

    def build_and_authorize_scope(as: :default)
      authorized(@parent.collectivities, as:).strict_loading
    end
  end
end
