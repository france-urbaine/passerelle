# frozen_string_literal: true

module Layout
  class DatatableComponent < ApplicationViewComponent
    define_component_helper :datatable_component

    renders_many :columns, "Column"
    renders_one :empty_message

    renders_one :search,     ->(*args, **kwargs) { Search.new(self, *args, **kwargs) }
    renders_one :pagination, ->(*args, **kwargs) { Pagination.new(self, *args, **kwargs) }
    renders_one :selection,  ->(*args, **kwargs) { Layout::Datatable::SelectionComponent.new(self, *args, **kwargs) }

    attr_reader :records, :rows, :turbo_frame, :pagy

    def initialize(records, id: nil)
      @records     = records
      @rows        = []
      @turbo_frame = id || "datatable-#{records.model_name.route_key}"
      super()
    end

    def each_row(&)
      return if request.headers["Turbo-Frame"] == turbo_frame_selection_bar

      @records.each do |record|
        row = Datatable::RowComponent.new(self, record)
        yield row, record
        @rows << row
      end
    end

    def checkboxes?
      @rows.any?(&:checkbox?)
    end

    def actions?
      @rows.any? { |row| row.actions.any? }
    end

    def order_columns?
      columns.any?(&:sort?)
    end

    def turbo_frame_selection_bar
      "#{turbo_frame}-selection-bar"
    end

    class Search < ApplicationViewComponent
      def initialize(datatable, label = nil)
        @datatable = datatable
        @label     = label
        super()
      end

      def call
        options = { turbo_frame: @datatable.turbo_frame }
        options[:label] = @label if @label

        render UI::Form::SearchForm::Component.new(**options)
      end
    end

    class Pagination < ApplicationViewComponent
      def initialize(datatable, pagy, *, options: true, **)
        @datatable   = datatable
        @pagy        = pagy
        @options     = options
        @inflections = InflectionsOptions.new(*, **) || InflectionsOptions.new(@datatable.records.model)
        super()
      end

      def call
        render Layout::Pagination::Component.new(
          @pagy,
          @inflections,
          turbo_frame: @datatable.turbo_frame,
          direction:   "left",
          options:     @options,
          order:       order_options
        )
      end

      delegate :count, to: :@pagy

      def pages_count
        @pagy.pages
      end

      def order_options
        @datatable.columns.select(&:sort?).to_h do |column|
          [column.key, column.to_s]
        end
      end
    end

    class Column < ApplicationViewComponent
      attr_reader :key, :colspan

      def initialize(key, sort: false, numeric: false, compact: false, span: 1)
        @key     = key
        @sort    = sort
        @numeric = numeric
        @compact = compact
        @colspan = span
        super()
      end

      def sort?
        @sort
      end

      def sort_key
        @sort.is_a?(String) ? @sort : @key
      end

      def numeric?
        @numeric
      end

      def compact?
        @compact
      end

      def colgroup?
        @colspan && @colspan > 1
      end

      def call
        content
      end

      def css_class
        css = ""
        css += " w-px" if compact?
        css += " text-right" if numeric?
        css += " w-1 pl-12" if numeric? && !compact?
        css.strip.presence
      end
    end

    class OrderColumn < ApplicationViewComponent
      attr_reader :key, :turbo_frame

      def initialize(key, turbo_frame: "_top")
        @key         = key
        @turbo_frame = turbo_frame
        super()
      end

      def call
        render button
      end

      def button
        UI::Button::Component.new(
          label,
          url,
          icon:      icon,
          icon_only: true,
          class:     css_classes,
          data:      { turbo_frame: }
        )
      end

      DIRECTION = {
        asc:  { label: "Trier par ordre croissant",   icon: "arrow-small-up" },
        desc: { label: "Trier par ordre décroissant", icon: "arrow-small-down" }
      }.freeze

      def label
        DIRECTION[direction][:label]
      end

      def icon
        DIRECTION[direction][:icon]
      end

      def url
        new_params = params.slice(:limit, :search).permit!
        new_params[:order] = direction == :asc ? key : "-#{key}"

        url_for(new_params)
      end

      def css_classes
        css = "datatable__order-button"
        css += " datatable__order-button--current" if current?
        css
      end

      def direction
        current? && current_order_direction == :asc ? :desc : :asc
      end

      def current?
        current_order_key == @key.to_s
      end

      def current_order
        @current_order ||= params[:order].presence
      end

      def current_order_key
        @current_order_key ||= current_order&.slice(/^^-?(.+)$/, 1)
      end

      def current_order_direction
        @current_order_direction ||= current_order && (current_order[0] == "-" ? :desc : :asc)
      end
    end
  end
end
