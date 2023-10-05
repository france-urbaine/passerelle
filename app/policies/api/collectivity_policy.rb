# frozen_string_literal: true

module API
  class CollectivityPolicy < ApplicationPolicy
    def create?
      record.publisher_id == publisher.id
    end
  end
end
