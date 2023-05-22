# frozen_string_literal: true

module Collectivities
  class OfficesController < ::OfficesController
    private

    def scope_offices
      collectivity = Collectivity.find(params[:collectivity_id])

      only_kept! collectivity
      only_kept! collectivity.publisher

      @parent  = collectivity
      @offices = collectivity.assigned_offices
    end
  end
end
