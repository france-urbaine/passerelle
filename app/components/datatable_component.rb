# frozen_string_literal: true

class DatatableComponent < ViewComponent::Base
  renders_one :empty_message
  renders_one :selection, "Selection"
  renders_one :actions
  renders_many :columns, "Column"

  attr_reader :records, :rows

  def initialize(records)
    @records = records
    @rows    = []
    super()
  end

  def each_row(&)
    @records.each do |record|
      row = ::Datatable::RowComponent.new(self, record)
      yield row, record
      @rows << row
    end
  end

  class Selection < ViewComponent::Base
    attr_reader :label

    def initialize(label = nil)
      @label = label
      super()
    end
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
