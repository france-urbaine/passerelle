# frozen_string_literal: true

module Collectivities
  class OfficesController < ::OfficesController
    private

    def load_and_authorize_parent
      collectivity = Collectivity.find(params[:collectivity_id])

      authorize! collectivity, to: :show?
      only_kept! collectivity
      only_kept! collectivity.publisher

      @parent = collectivity
    end

    def build_and_authorize_scope(as: :default)
      authorized(@parent.assigned_offices, as:).strict_loading
    end
  end
end
