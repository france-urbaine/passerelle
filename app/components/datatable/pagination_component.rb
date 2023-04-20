# frozen_string_literal: true

module Datatable
  class PaginationComponent < ViewComponent::Base
    def initialize(datatable)
      @datatable = datatable
      super()
    end

    def page_url(page)
      new_params = params.slice(:search, :order).permit!
      new_params[:page] = page
      helpers.url_for(new_params)
    end
  end
end
