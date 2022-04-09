# frozen_string_literal: true

module Datatable
  class PaginationFooterComponent < ViewComponent::Base
    attr_reader :pagy

    def initialize(pagy)
      @pagy = pagy
    end

    def placeholder
      "Page #{pagy.page} / #{pagy.pages}"
    end
  end
end
