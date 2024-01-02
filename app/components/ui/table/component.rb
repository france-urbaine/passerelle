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

        def initialize(key, sort: false, right: false, compact: false, span: 1, **options)
          @key       = key
          @sort      = sort
          @right     = right
          @compact   = compact
          @span_size = span || 1
          @options   = options
          super()
        end

        %i[sort compact right].each do |method|
          define_method :"#{method}?" do
            instance_variable_get :"@#{method}"
          end
        end

        def multi_span?
          @span_size > 1
        end

        def call
          if content?
            content
          else
            html_escape(key.to_s.humanize)
          end
        end

        def html_attributes
          scope = "col"

          if multi_span?
            scope   = "colgroup"
            colspan = @span_size
          end

          { class: css_class, scope:, colspan: }
        end

        def css_class
          css_class = %w[table__cell]
          css_class << "table__cell--compact" if compact?
          css_class << "table__cell--right" if right?
          css_class += Array.wrap(@options[:class])
          css_class.join(" ").squish
        end
      end

      class Row < ApplicationViewComponent
        renders_one :checkbox, ->(*args, **options) { RowCheckbox.new(self, @datum, *args, **options) }
        renders_many :actions, ->(*args, **options) { ActionSlot.new(*args, **options, icon_only: true) }
        renders_many :columns, "UI::Table::Component::RowColumn"

        attr_reader :cells

        def initialize(datatable, datum, **options)
          @datatable = datatable
          @datum     = datum
          @options   = options
          @cells     = []
          super()
        end

        def before_render
          # Create & eager load cells for each column in head
          @datatable.columns.each do |head_column|
            row_column = columns.find { |column| column.key == head_column.key }

            if row_column
              convert_column_to_cells(head_column, row_column)
            else
              create_cell(head_column)
            end
          end

          @cells.each { |cell| render(cell) }
        end

        def call
          "".html_safe
        end

        def html_attributes
          options = @options.dup
          data    = options.fetch(:data, {})

          if checkbox?
            data_controller = %w[selection-row]
            data_controller += Array.wrap(data[:controller])

            data[:controller] = data_controller.join(" ").squish
            data[:selection_row_selected_class] = "table__row--selected"
          end

          options.merge(data: data)
        end

        def dom_id
          @dom_id ||=
            if @datum.respond_to?(:to_key)
              helpers.dom_id(@datum)
            else
              SecureRandom.alphanumeric(6)
            end
        end

        private

        def create_cell(head_column, row_column = nil, **, &)
          cell = RowCell.new(self, head_column, row_column, **)

          if block_given?
            content = helpers.capture(&)
            cell.with_content(content)
          end

          @cells << cell
          cell
        end

        def convert_column_to_cells(head_column, row_column)
          # Eager load column content to load spans
          key     = head_column.key
          colspan = head_column.span_size
          content = column_content(row_column)
          spans   = row_column.spans

          if spans.any?
            raise "Unexpected spans in columns #{head_column.key}" if colspan <= 1
            raise "Column #{key} is expected #{colspan} spans, got #{spans.size}" if spans.size != colspan

            spans.each_with_index do |span, index|
              create_cell(head_column, nil, span_index: index) { span.to_s }
            end
          else
            create_cell(head_column, row_column) { content }
          end
        end

        def column_content(row_column)
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
        renders_many :spans

        attr_reader :key, :options

        def initialize(key, **options)
          @key     = key
          @options = options
          super()
        end

        def call
          content
        end
      end

      class RowCell < ApplicationViewComponent
        renders_many :spans

        attr_reader :key

        delegate :right?, to: :@head_column

        def initialize(row, head_column, row_column = nil, span_index: nil, **options)
          @row         = row
          @head_column = head_column
          @row_column  = row_column
          @span_index  = span_index
          @options     = options
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
          options = @options.dup

          options[:id]   = dom_id if options[:id] == true
          options[:id] ||= dom_id if @row.checkbox&.described_by == @head_column.key

          options[:class]   = css_class
          options[:colspan] = colspan
          options
        end

        def dom_id
          [@head_column.key, @row.dom_id].compact.join("-")
        end

        def colspan
          @head_column.span_size if @head_column.multi_span? && @span_index.nil?
        end

        def css_class
          css_class = %w[table__cell]
          css_class << "table__cell--compact" if compact?
          css_class << "table__cell--right" if right?
          css_class += Array.wrap(@options[:class])
          css_class.join(" ").squish
        end
      end

      class RowCheckbox < ApplicationViewComponent
        attr_reader :label, :described_by

        def initialize(row, datum, label = nil, value: nil, described_by: nil, **options)
          @row          = row
          @datum        = datum
          @label        = label
          @value        = value
          @described_by = described_by
          @options      = options
          super()
        end

        def call
          tag.input(
            type:  "checkbox",
            value: value,
            aria:  {
              label:       label || t(".check_row"),
              describedby: describedby_id
            },
            data: {
              selection_target:     "checkbox",
              selection_row_target: "checkbox"
            },
            **@options
          )
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

        def describedby_id
          [@described_by, @row.dom_id].compact.join("-")
        end
      end
    end
  end
end
