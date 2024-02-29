# frozen_string_literal: true

module UI
  module Form
    module SearchForm
      class Component < ApplicationViewComponent
        define_component_helper :search_form_component

        def initialize(label: "Rechercher", turbo_frame: "_top", url: nil, value: nil)
          @label       = label
          @turbo_frame = turbo_frame
          @url         = url
          @value       = value
          super()
        end
      end
    end
  end
end