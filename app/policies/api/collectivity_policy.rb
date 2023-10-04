# frozen_string_literal: true

module API
  class CollectivityPolicy < ApplicationPolicy
    def create?
      record.publisher_id = publisher.id
    end

    private

    def collectivities_listed_to_publisher
      return Collectivity.none if publisher.blank?

      Collectivity.owned_by(publisher)
    end
  end
end
