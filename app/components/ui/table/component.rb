# frozen_string_literal: true

module UI
  module Table
    class Component < ApplicationViewComponent
      define_component_helper :table_component

      renders_many :columns, "HeadColumn"

      attr_reader :data, :rows

      def initialize(data)
        @data = data
        @rows = []
        super()
      end

      def before_render
        # Eager load columns & rows
        content
        rows.each { |row| render(row) }
      end

      def each_row(&)
        return to_enum(:each_row) unless block_given?

        @data.each do |datum|
          row = Row.new(self, datum)
          yield row, datum
          @rows << row
        end
      end

      def checkboxes?
        @rows.any?(&:checkbox?)
      end

      def actions?
        @rows.any?(&:actions?)
      end

      class HeadColumn < ApplicationViewComponent
        attr_reader :key, :span_size

        def initialize(key, sort: false, right: false, compact: false, span: 1, **)
          @key             = key
          @sort            = sort
          @right           = right
          @compact         = compact
          @span_size       = span || 1
          @html_attributes = parse_html_attributes(**)
          super()
        end

        def call
          if content?
            content
          else
            html_escape(key.to_s.humanize)
          end
        end

        def sort?
          @sort
        end

        def compact?
          @compact
        end

        def right?
          @right
        end

        def multi_span?
          @span_size > 1
        end

        def html_attributes
          attributes = reverse_merge_attributes(@html_attributes, {
            scope: "col",
            class: [
              "table__cell",
              ("table__cell--compact" if compact?),
              ("table__cell--right"   if right?)
            ]
          })

          if multi_span?
            attributes[:scope]   = "colgroup"
            attributes[:colspan] = @span_size
          end

          attributes
        end
      end

      class Row < ApplicationViewComponent
        renders_one :checkbox, ->(*args, **options) { RowCheckbox.new(self, @datum, *args, **options) }
        renders_many :actions, ->(*args, **options) { ActionSlot.new(*args, **options, icon_only: true) }
        renders_many :columns, "UI::Table::Component::RowColumn"

        attr_reader :cells

        def initialize(datatable, datum, **)
          @datatable       = datatable
          @datum           = datum
          @html_attributes = parse_html_attributes(**)
          @cells           = []
          super()
        end

        def before_render
          # Create & eager load cells for each column in head
          convert_columns_to_cells
          @cells.each { |cell| render(cell) }
        end

        def call
          # Render an empty string to allow eager loading without rendering anything
          "".html_safe
        end

        def head_columns
          @datatable.columns
        end

        def html_attributes
          attributes = reverse_merge_attributes(@html_attributes, {
            class: "table__row"
          })

          if checkbox?
            attributes = reverse_merge_attributes(attributes, {
              data: {
                controller: "selection-row",
                selection_row_selected_class: "table__row--selected"
              }
            })
          end

          attributes
        end

        def component_dom_id(*)
          @component_dom_id ||= helpers.dom_id(@datum) if @datum.respond_to?(:to_key)

          super(*)
        end

        private

        def convert_columns_to_cells
          head_columns.each do |head_column|
            key        = head_column.key
            colspan    = head_column.span_size
            row_column = columns.find { |column| column.key == head_column.key }

            if row_column.nil?
              create_cell(head_column)
              next
            end

            # Eager load column content to load spans
            content = load_column_content(row_column)
            spans   = row_column.spans

            if spans.any?
              raise "Unexpected spans in columns #{head_column.key}" if colspan <= 1
              raise "Column #{key} is expected #{colspan} spans, got #{spans.size}" if spans.size != colspan

              spans.each_with_index do |span, index|
                create_cell(head_column, span_index: index, **span.html_attributes) { span.to_s }
              end
            else
              create_cell(head_column, **row_column.html_attributes) { content }
            end
          end
        end

        def create_cell(head_column, **, &)
          cell = Cell.new(self, head_column, **)

          if block_given?
            content = helpers.capture(&)
            cell.with_content(content)
          end

          @cells << cell
          cell
        end

        def load_column_content(row_column)
          return row_column.to_s if row_column.content?

          key = row_column.key

          if @datum.is_a?(Hash) && @datum.key?(key)
            @datum.fetch(key)&.to_s
          elsif @datum.respond_to?(key)
            @datum.public_send(key)&.to_s
          else
            raise ArgumentError, "cannot read #{key} on #{@datum}"
          end
        end
      end

      class RowColumn < ApplicationViewComponent
        renders_many :spans, "UI::Table::Component::RowSpan"

        attr_reader :key, :html_attributes

        def initialize(key, **)
          @key = key
          @html_attributes = parse_html_attributes(**)
          super()
        end

        def call
          content
        end
      end

      class RowSpan < ApplicationViewComponent
        attr_reader :html_attributes

        def initialize(**)
          @html_attributes = parse_html_attributes(**)
          super()
        end

        def call
          content
        end
      end

      class RowCheckbox < ApplicationViewComponent
        attr_reader :label, :described_by

        def initialize(row, datum, label = nil, value: nil, described_by: nil, **)
          @row             = row
          @datum           = datum
          @label           = label
          @value           = value
          @described_by    = described_by
          @html_attributes = parse_html_attributes(**)
          super()
        end

        def call
          tag.input(type: "checkbox", value: value, **html_attributes)
        end

        def value
          @value ||=
            if @datum.respond_to?(:id)
              @datum.id
            elsif @datum.is_a?(Hash) && @described_by && @datum.key?(@described_by)
              @datum.fetch(@described_by)
            else
              raise ArgumentError, "cannot infer a checkbox value for #{@datum}"
            end
        end

        def html_attributes
          reverse_merge_attributes(@html_attributes, {
            aria:  {
              label:       label || t(".check_row"),
              describedby: aria_describedby
            },
            data: {
              selection_target:     "checkbox",
              selection_row_target: "checkbox"
            }
          })
        end

        def aria_describedby
          return unless @described_by

          head_column = @row.head_columns.find { _1.key == @described_by }
          row_column  = @row.columns.find { _1.key == @described_by }

          if head_column.nil?
            warning = "the column #{@described_by.inspect} in :described_by cannot be found"
          elsif row_column.nil?
            warning = "the column #{@described_by.inspect} in :described_by cannot be found in row"
          elsif head_column.span_size > 1
            warning = "the column #{@described_by.inspect} in :described_by cannot be applied because of multiple spans"
          end

          if warning
            Rails.logger.warn(warning)
            nil
          else
            @row.component_dom_id(@described_by)
          end
        end
      end

      class Cell < ApplicationViewComponent
        delegate :key, :right?, to: :@head_column

        def initialize(row, head_column, span_index: nil, **)
          @row         = row
          @head_column = head_column
          @span_index  = span_index
          @html_attributes = parse_html_attributes(**)
          super()
        end

        def call
          content
        end

        def compact?
          @head_column.compact? || (@head_column.multi_span? && !last_span?)
        end

        def last_span?
          @span_index && @span_index == @head_column.span_size - 1
        end

        def html_attributes
          attributes = reverse_merge_attributes(@html_attributes, {
            class: [
              "table__cell",
              ("table__cell--compact" if compact?),
              ("table__cell--right"   if right?)
            ]
          })

          if @span_index.nil?
            attributes[:id]      = @row.component_dom_id(key) if key == @row.checkbox&.described_by
            attributes[:colspan] = @head_column.span_size     if @head_column.multi_span?
          end

          attributes
        end
      end
    end
  end
end
