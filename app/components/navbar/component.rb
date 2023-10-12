# frozen_string_literal: true

module Navbar
  class Component < ApplicationViewComponent
    renders_one  :header
    renders_many :sections, "Section"

    def initialize(**options)
      @options = options
      super()
    end

    def before_render
      content
      sections.each(&:to_s)

      @links = sections.flat_map(&:links)
    end

    def navbar_html_attributes
      options = @options.dup
      options[:class] = Array.wrap(options[:class])
      options[:class].unshift("navbar")
      options
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
        link.to_s,
        link.href,
        disabled: link.disabled?,
        class:    css_classes,
        **link.options
      )
    end

    def render_icon_link(link)
      tag.div(class: "navbar__icon-link") do
        button_component(
          link.to_s,
          link.href,
          disabled: link.disabled?,
          icon_only: true,
          **link.options
        )
      end
    end

    class Link < ApplicationViewComponent
      attr_reader :href, :options

      def initialize(*args, disabled: false, **options)
        raise ArgumentError, "wrong number of arguments (given #{args.size}, expected 1..2)" unless (1..2).include?(args.size)

        if args.size == 1
          @href = args[0]
        else
          @text = args[0]
          @href = args[1]
        end

        @disabled = disabled
        @options  = options
        super()
      end

      def disabled?
        @disabled || href.nil?
      end

      def call
        @text || content
      end
    end

    class Section < ApplicationViewComponent
      renders_many :links, Link

      attr_reader :title

      def initialize(title = nil)
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
