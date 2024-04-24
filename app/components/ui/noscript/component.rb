# frozen_string_literal: true

module UI
  module Noscript
    class Component < ApplicationViewComponent
      define_component_helper :noscript_component

      def initialize(id: nil)
        parse_html_attributes(id:)
        super()
      end
    end
  end
end
