# frozen_string_literal: true

module Layout
  class NavbarComponent < ApplicationViewComponent
    renders_one  :header
    renders_many :sections, "Section"

    def initialize(**options)
      @options = options
      super()
    end

    def before_render
      # eagerload all components & children components
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

    def links_with_icons
      @links.select(&:icon?)
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
        unless (1..2).cover?(args.size)
          raise ArgumentError, "wrong number of arguments (given #{args.size}, expected 1..2)"
        end

        @args = args
        @disabled = disabled
        @options  = options
        super()
      end

      def disabled?
        @disabled || href.nil?
      end

      def icon?
        @options[:icon]
      end

      def before_render
        if @args.size == 1 && content?
          @href = @args[0]
          @text = content
        elsif @args.size == 1
          @text = @args[0]
        else
          @text = @args[0]
          @href = @args[1]
        end
      end

      def call
        html_escape(@text)
      end
    end

    class Section < ApplicationViewComponent
      renders_many :links, Link
      renders_many :subsections, self

      attr_reader :title

      def initialize(title = nil)
        @title = title
        super()
      end

      def before_render
        # eagerload all components & children components
        content
        subsections.each(&:to_s)
        links.each(&:to_s)
      end

      def call
        ""
      end

      def empty_links?
        links.empty? && subsections.all?(&:empty_links?)
      end
    end
  end
end
