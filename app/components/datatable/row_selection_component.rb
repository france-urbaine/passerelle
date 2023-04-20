# frozen_string_literal: true

module Datatable
  class RowSelectionComponent < ViewComponent::Base
    attr_reader :reader, :label

    def initialize(record, label = nil, described_by: nil, disabled: false)
      @record       = record
      @label        = label
      @described_by = described_by
      @disabled     = disabled
      super()
    end

    def value
      @record.id
    end

    def checked?
      params[:ids].is_a?(Array) && params[:ids].include?(@record.id)
    end

    def disabled?
      @disabled
    end

    def aria_describedby
      helpers.dom_id(@record, @described_by) if @described_by
    end
  end
end
