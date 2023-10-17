# frozen_string_literal: true

module Layout
  class SearchFormComponent < ApplicationViewComponent
    def initialize(label: "Rechercher", turbo_frame: "_top", url: nil, value: nil)
      @label       = label
      @turbo_frame = turbo_frame
      @url         = url
      @value       = value
      super()
    end
  end
end
