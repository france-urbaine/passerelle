# frozen_string_literal: true

module Breadcrumbs
  class Component < ApplicationViewComponent
    renders_many :paths, "Path"
    renders_many :actions, ::Button::Component

    def initialize(heading: true)
      @heading = heading
      super()
    end

    class Path < ApplicationViewComponent
      def initialize(title, href_arg = nil, href: nil)
        @title = title
        @href = href_arg || href
        super()
      end

      def call
        if @href
          link_to @title, @href, data: { turbo_frame: "_top" }
        else
          @title
        end
      end
    end
  end
end
