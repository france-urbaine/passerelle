# frozen_string_literal: true

module Datatable
  class SearchComponent < ViewComponent::Base
    attr_reader :label

    def initialize(label: "Rechercher")
      @label = label
      super()
    end
  end
end
