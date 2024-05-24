# frozen_string_literal: true

module Layout
  module ContentLayout
    class Component < ApplicationViewComponent
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

      attr_reader :html_attributes

      def initialize(**)
        @html_attributes = parse_html_attributes(**)
        super()
      end

      def before_render
        # Eager loading all blocks
        content
        blocks.each(&:to_s)
      end

      class Block < ApplicationViewComponent
        attr_reader :html_attributes

        def initialize(**)
          @html_attributes = parse_html_attributes(**)
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
          merge_attributes(@html_attributes, {
            class: ("content__header--title" if @title)
          })
        end
      end

      class Grid < Block
        renders_many :columns, "Layout::ContentLayout::Component::Column"

        def before_render
          # Eager loading all column blocks
          columns.each(&:to_s)
        end

        def html_attributes
          return @html_attributes if @html_attributes.include?(:class)

          css_class =
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

          merge_attributes(@html_attributes, { class: css_class })
        end
      end

      class Column < Block
        renders_many :blocks, types: {
          header: {
            as:      :header,
            renders: "Layout::ContentLayout::Component::Header"
          },
          header_bar: {
            as:      :header_bar,
            renders: "Layout::ContentLayout::Component::HeaderBar"
          },
          section: {
            as:      :section,
            renders: "Layout::ContentLayout::Component::Section"
          },
          raw_block:  {
            as:      :raw_block,
            renders: "Layout::ContentLayout::Component::Block"
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
end
