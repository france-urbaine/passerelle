# frozen_string_literal: true

module Layout
  class ContentLayoutComponent < ApplicationViewComponent
    define_component_helper :content_layout_component

    renders_one :breadcrumbs, "BreadcrumbsSlot"
    renders_many :blocks, types: {
      header: {
        as:      :header,
        renders: "Header"
      },
      section: {
        as:      :section,
        renders: "Section"
      },
      grid: {
        as:      :grid,
        renders: "Grid"
      },
      raw_block:  {
        as:      :raw_block,
        renders: "Block"
      }
    }

    def initialize(**html_attributes)
      @html_attributes = html_attributes
      super()
    end

    def before_render
      # Eager loading all blocks
      content
      blocks.each(&:to_s)
    end

    class Block < ApplicationViewComponent
      attr_reader :html_attributes

      def initialize(**html_attributes)
        @html_attributes = html_attributes
        super()
      end

      def call
        content
      end

      def component_class_name
        self.class.name.demodulize
      end

      def header?
        false
      end
    end

    class Section < Block
    end

    class Header < Block
      renders_many :actions, "ActionSlot"

      def initialize(title: true, icon: nil, icon_options: {}, **)
        @title = title
        @icon = icon
        @icon_options = icon_options
        super(**)
      end

      def header?
        true
      end

      def call
        if @title
          tag.h2 do
            concat icon_component(@icon, **@icon_options) if @icon
            concat content
          end
        else
          concat icon_component(@icon, **@icon_options) if @icon
          concat content
        end
      end

      def html_attributes
        css_class = []
        css_class << "content__header--title" if @title
        css_class << @html_attributes[:class]
        css_class = css_class.join(" ").squish

        @html_attributes.merge(class: css_class)
      end
    end

    class Grid < Block
      renders_many :columns, "Layout::ContentLayoutComponent::Column"

      def before_render
        # Eager loading all column blocks
        columns.each(&:to_s)
      end

      def html_attributes
        css_class = @html_attributes.fetch(:class) do
          case columns.size
          when 0, 1 then nil
          when 2 then "content__grid--cols-2"
          else
            raise ArgumentError, <<~MESSAGE
              No default CSS class found for content layout grid with #{columns.size} columns.
              You must add it to `with_grid` :

              with_grid(class: "xl:grid-cols-#{columns.size}) do
                [...]
              end
            MESSAGE
          end
        end

        @html_attributes.merge(class: css_class)
      end
    end

    class Column < Block
      renders_many :blocks, types: {
        header: {
          as:      :header,
          renders: "Layout::ContentLayoutComponent::Header"
        },
        header_bar: {
          as:      :header_bar,
          renders: "Layout::ContentLayoutComponent::HeaderBar"
        },
        section: {
          as:      :section,
          renders: "Layout::ContentLayoutComponent::Section"
        },
        raw_block:  {
          as:      :raw_block,
          renders: "Layout::ContentLayoutComponent::Block"
        }
      }

      def before_render
        # Eager loading all column blocks
        content
        blocks.each(&:to_s)
      end
    end
  end
end
