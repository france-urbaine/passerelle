# frozen_string_literal: true

module UI
  class BreadcrumbsComponent < ApplicationViewComponent
    renders_many :paths, "Path"
    renders_many :actions, lambda { |*args, **options, &block|
      if args.any? || options.any?
        ButtonComponent.new(*args, **options)
      else
        block.call
      end
    }

    def initialize(heading: true)
      @heading = heading
      super()
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
