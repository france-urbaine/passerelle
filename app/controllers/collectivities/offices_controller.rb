# frozen_string_literal: true

module Collectivities
  class OfficesController < ::OfficesController
    before_action do
      collectivity = Collectivity.find(params[:collectivity_id])

      next gone(collectivity) if collectivity.discarded?
      next gone(collectivity.publisher) if collectivity.publisher.discarded?

      @parent = collectivity
      @offices_scope = collectivity.assigned_offices
    end
  end
end
