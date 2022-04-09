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
      helpers.url_for(page: page)
    end
  end
end
