# frozen_string_literal: true

class PageHeaderComponent < ViewComponent::Base
  renders_many :breadcrumbs_paths, "BreadcrumbsPath"
  renders_many :actions, "Action"

  class BreadcrumbsPath < ViewComponent::Base
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

  class Action < ViewComponent::Base
    def initialize(title, href: nil, icon: nil, modal: false, primary: false, **options)
      @title = title
      @href = href
      @icon = icon
      @modal = modal
      @primary = primary
      @options = options
      super()
    end

    def call
      if @href
        link_to @href, **link_options do
          concat helpers.svg_icon(@icon) if @icon
          concat @title
        end
      else
        content_tag :button, **button_options do
          concat helpers.svg_icon(@icon) if @icon
          concat @title
        end
      end
    end

    def link_options
      options = button_options
      options[:data][:turbo_frame] = "modal" if @modal
      options
    end

    def button_options
      options = @options.dup

      options[:data] ||= {}

      options[:class] ||= ""
      options[:class] += " button"
      options[:class] += " button--primary" if @primary

      options
    end
  end
end
