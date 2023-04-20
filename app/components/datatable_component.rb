# frozen_string_literal: true

class DatatableComponent < ViewComponent::Base
  renders_one :search, ::Datatable::SearchComponent
  renders_one :selection, ::Datatable::SelectionComponent
  renders_one :empty_message
  renders_one :actions
  renders_many :columns, "Column"

  attr_reader :records, :rows, :pagy

  def initialize(records)
    @records = records
    @rows    = []
    super()
  end

  def before_render
    # Call selection to build its slots
    selection.to_s
  end

  def each_row(&)
    return if header_bar_only?

    @records.each do |record|
      row = ::Datatable::RowComponent.new(self, record)
      yield row, record
      @rows << row
    end
  end

  def with_pagination(pagy)
    @pagy = pagy
  end

  def with_inflections(singular, plural: nil, feminine: false)
    @singular_inflection = singular
    @plural_inflection   = plural || singular.pluralize
    @feminine_inflection = feminine
  end

  def singular_inflection
    @singular_inflection || raise("inflections are not defined in #{self}")
  end

  def plural_inflection
    @plural_inflection ||= singular_inflection.pluralize
  end

  def feminine_inflection?
    @feminine_inflection
  end

  def header_bar_only?
    helpers.turbo_frame_request_id == "datatable-header-bar"
  end

  def selection_active?
    selection? && params[:ids].present?
  end

  def pagination?
    @pagy
  end

  class Column < ViewComponent::Base
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
      css += " w-48" if numeric? && !compact?
      css.strip.presence
    end
  end
end
