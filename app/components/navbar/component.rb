# frozen_string_literal: true

module Navbar
  class Component < ApplicationViewComponent
    renders_one  :header
    renders_many :sections, "Section"

    def before_render
      content
      sections.each(&:to_s)

      @links = sections.flat_map(&:links)
    end

    def render_link(link)
      href = link.href

      current =
        if link.disabled?
          false
        elsif href == "/"
          href == request.path
        else
          request.fullpath.start_with?(href)
        end

      css_classes  = "navbar__link"
      css_classes += " navbar__link--current" if current

      button_component(
        link.text,
        link.href,
        disabled: link.disabled?,
        class:    css_classes,
        **link.options
      )
    end

    def render_icon_link(link)
      tag.div(class: "navbar__icon-link") do
        button_component(
          link.text,
          link.href,
          disabled: link.disabled?,
          icon_only: true,
          **link.options
        )
      end
    end

    class Link < ApplicationViewComponent
      attr_reader :text, :href, :options

      def initialize(text, href = nil, disabled: false, **options)
        @text = text
        @href = href

        @disabled = disabled
        @options  = options
        super()
      end

      def disabled?
        @disabled || href.nil?
      end
    end

    class Section < ApplicationViewComponent
      renders_many :links, Link

      attr_reader :title

      def initialize(title)
        @title = title
        super()
      end

      def before_render
        content
      end

      def call
        ""
      end
    end
  end
end
