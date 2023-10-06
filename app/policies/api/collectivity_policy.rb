# frozen_string_literal: true

module API
  class CollectivityPolicy < ApplicationPolicy
    alias_rule :index?, to: :read?
    alias_rule :show?, to: :not_supported

    def read?
      if record == Collectivity
        publisher?
      elsif record.is_a?(Collectivity)
        publisher? && record.publisher_id == publisher.id
      end
    end
  end
end
