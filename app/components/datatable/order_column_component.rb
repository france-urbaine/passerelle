# frozen_string_literal: true

module Datatable
  class OrderColumnComponent < ViewComponent::Base
    attr_reader :key

    def initialize(key)
      @key = key
    end

    def current?
      helpers.current_order_key == @key.to_s
    end

    def current_asc?
      current? && helpers.current_order_direction == :asc
    end

    def current_desc?
      current? && helpers.current_order_direction == :desc
    end

    def order_url(direction = :asc)
      new_params = params.slice(:items, :search).permit!
      new_params[:order] = direction == :asc ? key : "-#{key}"

      helpers.url_for(new_params)
    end
  end
end
