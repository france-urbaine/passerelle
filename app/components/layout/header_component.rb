# frozen_string_literal: true

module Layout
  class HeaderComponent < ViewComponent::Base
    renders_many :breadcrumbs_paths, "Path"
    renders_one  :primary_action, "PrimaryAction"
    renders_many :actions, "Action"

    class Path < ViewComponent::Base
      def initialize(title, href: nil)
        @title = title
        @href = href
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

    class Action < ::ButtonComponent
    end

    class PrimaryAction < ::ButtonComponent
      def initialize(*args, **options)
        super(*args, **options, primary: true)
      end
    end
  end
end
