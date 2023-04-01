# frozen_string_literal: true

module Datatable
  class OrderColumnComponent < ViewComponent::Base
    include CurrentOrderParams

    attr_reader :key

    def initialize(key)
      @key = key
      super()
    end

    def current?
      current_order_key == @key.to_s
    end

    def current_asc?
      current? && current_order_direction == :asc
    end

    def current_desc?
      current? && current_order_direction == :desc
    end

    def order_url(direction = :asc)
      new_params = params.slice(:items, :search).permit!
      new_params[:order] = direction == :asc ? key : "-#{key}"

      # FIXME: https://github.com/ViewComponent/lookbook/issues/328
      if params[:controller]&.start_with?("lookbook")
        helpers.lookbook.url_for(new_params)
      else
        helpers.url_for(new_params)
      end
    end
  end
end
