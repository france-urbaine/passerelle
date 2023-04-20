# frozen_string_literal: true

module Datatable
  class IndexOptionsComponent < ViewComponent::Base
    def initialize(datatable)
      @datatable = datatable
      super()
    end

    def items_url(items)
      new_params = params.slice(:search, :order).permit!
      new_params[:items] = items
      helpers.url_for(new_params)
    end

    def sorted_options
      @sorted_options ||= @datatable.columns.select(&:sort?).to_h do |column|
        label = column.to_s
        label = label.downcase unless label.match?(/\A[A-Z]+\Z/)
        label

        [column.key, label]
      end
    end

    def order_url(key, direction = :asc)
      new_params = params.slice(:search).permit!
      new_params[:order] = direction == :asc ? key : "-#{key}"
      helpers.url_for(new_params)
    end

    delegate :current_order_key, :current_order_direction, to: :helpers

    def current_order?(key)
      current_order_key == key.to_s
    end

    def current_asc_order?(key)
      current_order?(key) && current_order_direction == :asc
    end

    def current_desc_order?(key)
      current_order?(key) && current_order_direction == :desc
    end
  end
end
