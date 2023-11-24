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

    def wrap(&)
      Current.wrap(self, &)
    end

    class Block < ApplicationViewComponent
      def component_class_name
        self.class.name.demodulize
      end

      def call
        content
      end
    end

    class Header < Block
      renders_many :actions, "ActionSlot"

      def initialize(icon: nil, icon_options: {})
        @icon = icon
        @icon_options = icon_options
        super()
      end

      def icon
        # TODO: Should we add an ARIA label to the icon ?

        icon_component(@icon, **@icon_options) if @icon
      end
    end

    class Section < Block
    end

    class Grid < Block
      renders_many :columns, "Layout::ContentLayoutComponent::Column"

      def initialize(**html_attributes)
        @html_attributes = html_attributes
        super()
      end

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

      def wrap(&)
        Current.wrap(self, &)
      end
    end

    module Current
      def current_layout_component(&)
        if Current.current
          yield Current.current
          ""
        else
          render Layout::ContentLayoutComponent.new, &
        end
      end

      def self.wrap(instance)
        Thread.current[:current_layout_component] = instance
        yield
        Thread.current[:current_layout_component] = nil
      end

      def self.current
        Thread.current[:current_layout_component]
      end
    end
  end
end
