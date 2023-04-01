# frozen_string_literal: true

module Datatable
  class RowComponent < ViewComponent::Base
    renders_one  :selection, ::Datatable::RowSelectionComponent
    renders_many :actions,   "Action"
    renders_many :columns,   "Column"
    renders_many :cells,     "Cell"

    attr_reader :record, :datatable

    delegate :selection?, :actions?, to: :datatable, prefix: :head

    def initialize(datatable, record)
      @datatable = datatable
      @record    = record
      super()
    end

    # Slots
    # --------------------------------------------------------------------------
    def with_selection(...)
      set_slot(:selection, nil, record, ...)
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

    class Action < ::ButtonComponent
      def initialize(label, icon_only: true, **options)
        super(label, icon_only: icon_only, **options)
      end
    end

    class Column < ViewComponent::Base
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

    class Cell < ViewComponent::Base
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
          colspan: colspan
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
  end
end
