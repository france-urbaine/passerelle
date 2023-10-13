# frozen_string_literal: true

module Tabs
  class Component < ApplicationViewComponent
    renders_many :tabs, "Tab"

    class Tab < ApplicationViewComponent
      attr_reader :title, :block, :id

      def initialize(title, &block)
        @title = title
        @id    = title.parameterize
        @block = block
        super()
      end

      def call
        content_tag :div, content
      end
    end
  end
end
