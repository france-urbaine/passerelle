# frozen_string_literal: true

module Datatable
  class PaginationHeaderComponent < ViewComponent::Base
    attr_reader :pagy, :singular, :plural

    def initialize(pagy, singular, plural: nil)
      @pagy     = pagy
      @singular = singular
      @plural   = plural || singular.pluralize
    end

    def page_url(page)
      new_params = params.slice(:search, :order).permit!
      new_params[:page] = page

      helpers.url_for(new_params)
    end
  end
end
