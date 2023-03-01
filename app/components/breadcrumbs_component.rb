# frozen_string_literal: true

class BreadcrumbsComponent < ViewComponent::Base
  renders_many :paths, "Path"
  renders_many :actions, ::ButtonComponent

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
end
