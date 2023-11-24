# frozen_string_literal: true

module UI
  class BreadcrumbsComponent < ApplicationViewComponent
    define_component_helper :breadcrumbs_component

    renders_many :paths, "Path"
    renders_many :actions, "ActionSlot"

    def initialize(heading: true)
      @heading = heading
      super()
    end

    def home_label
      I18n.t(:home, scope: i18n_component_path)
    end

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
