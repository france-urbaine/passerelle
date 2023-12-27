# frozen_string_literal: true

module UI
  class BreadcrumbsComponent < ApplicationViewComponent
    define_component_helper :breadcrumbs_component

    renders_one :h1, "ContentSlot"
    renders_many :paths, "Path"
    renders_many :actions, "ActionSlot"

    class Path < ApplicationViewComponent
      def initialize(title = nil, href_arg = nil, href: nil)
        @title = title
        @href = href_arg || href
        super()
      end

      def call
        if @href
          link_to @title, @href, data: { turbo_frame: "_top" }
        elsif content?
          content
        else
          @title
        end
      end
    end
  end
end
