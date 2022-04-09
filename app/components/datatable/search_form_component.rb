# frozen_string_literal: true

module Datatable
  class SearchFormComponent < ViewComponent::Base
    attr_reader :label

    def initialize(label)
      @label = label
    end
  end
end
