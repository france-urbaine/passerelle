# frozen_string_literal: true

module UI
  module Noscript
    class Component < ApplicationViewComponent
      def initialize(id: nil)
        parse_html_attributes(id:)
        super()
      end
    end
  end
end
