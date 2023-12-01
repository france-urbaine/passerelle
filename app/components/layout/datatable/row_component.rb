# frozen_string_literal: true

module Layout
  module Datatable
    class RowComponent < ApplicationViewComponent
      renders_one :checkbox, lambda { |*args, **options|
        Checkbox.new(self, *args, **options)
      }

      renders_many :actions, lambda { |*args, **options|
        if args.empty? && options.empty?
          ContentSlot.new
        else
          UI::ButtonComponent.new(*args, **options, icon_only: true, data: { turbo_frame: "_top" })
        end
      }

      renders_many :columns,  "Column"
      renders_many :cells,    "Cell"

      attr_reader :record, :datatable

      def initialize(datatable, record)
        @datatable = datatable
        @record    = record
        super()
      end

      def datatable_checkboxes?
        @datatable.checkboxes?
      end

      def datatable_actions?
        @datatable.actions?
      end

      # Create cells
      # ----------------------------------------------------------------------------
      def before_render
        return if cells?

        @datatable.columns.each do |head_column|
          column = columns.find { |col| col.key == head_column.key }

          if column
            convert_column_to_cells(column, head_column)
          else
            create_cell(head_column)
          end
        end
      end

      def create_cell(head_column, &)
        with_cell(record, head_column.key, numeric: head_column.numeric?, span: head_column.colspan, &)
      end

      def convert_column_to_cells(column, head_column)
        # Call column content to load spans
        content = helpers.capture { column.to_s }

        if head_column.colgroup?
          if column.spans?
            convert_spans_to_cells(column.spans, head_column)
          else
            create_cell(head_column) { content }
          end
        else
          raise "Unexpected spans in columns #{column.key}" if column.spans?

          create_cell(head_column) { content }
        end
      end

      def convert_spans_to_cells(spans, head_column)
        raise "Column #{head_column.key} is expected #{head_column.colspan} spans" if spans.size != head_column.colspan

        spans[0..-2].each do |span|
          with_cell(record, nil, compact: true) do
            helpers.capture { span.to_s }
          end
        end

        with_cell(record, head_column.key, numeric: head_column.numeric?) do
          helpers.capture { spans.last.to_s }
        end
      end

      # Helpers
      # --------------------------------------------------------------------------
      def dom_id(key = nil)
        helpers.dom_id(record, key)
      end

      class Column < ApplicationViewComponent
        renders_many :spans

        attr_reader :key

        def initialize(key)
          @key = key
          super()
        end

        def call
          content
        end
      end

      class Cell < ApplicationViewComponent
        def initialize(record, key = nil, numeric: false, compact: false, span: 1)
          @record  = record
          @key     = key
          @numeric = numeric
          @compact = compact
          @colspan = span
          super()
        end

        def call
          tag.td(
            id: id,
            class: css_class,
            colspan: colspan,
            is: "turbo-frame"
          ) do
            content
          end
        end

        def id
          helpers.dom_id(@record, @key) if @key
        end

        def css_class
          css = ""
          css += " w-px" if @compact
          css += " text-right" if @numeric
          css.strip.presence
        end

        def colspan
          @colspan if @colspan && @colspan > 1
        end
      end

      class Checkbox < ApplicationViewComponent
        attr_reader :row, :record, :label

        def initialize(row, label = nil, described_by: nil, disabled: false)
          @row          = row
          @record       = row.record
          @label        = label
          @described_by = described_by
          @disabled     = disabled
          super()
        end

        def call
          tag.input(
            type:         "checkbox",
            value:        value,
            checked:      checked?,
            disabled:     disabled?,
            aria: {
              label:       (label || "Sélectionner cette ligne"),
              describedby: aria_describedby
            },
            data: {
              selection_target:     "checkbox",
              selection_row_target: "checkbox"
            }
          )
        end

        def value
          record.id
        end

        def checked?
          params[:ids].is_a?(Array) && params[:ids].include?(record.id)
        end

        def disabled?
          @disabled
        end

        def aria_describedby
          helpers.dom_id(record, @described_by) if @described_by
        end
      end
    end
  end
end
