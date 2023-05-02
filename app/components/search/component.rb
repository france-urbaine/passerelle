# frozen_string_literal: true

module Search
  class Component < ApplicationViewComponent
    attr_reader :label, :turbo_frame

    def initialize(label: "Rechercher", turbo_frame: "_top")
      @label       = label
      @turbo_frame = turbo_frame
      super()
    end
  end
end
