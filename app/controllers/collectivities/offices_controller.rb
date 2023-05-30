# frozen_string_literal: true

module Collectivities
  class OfficesController < ::OfficesController
    private

    def build_offices_scope
      collectivity = Collectivity.find(params[:collectivity_id])

      authorize! collectivity, to: :show?
      only_kept! collectivity
      only_kept! collectivity.publisher

      @parent  = collectivity
      @offices = collectivity.assigned_offices
    end
  end
end
