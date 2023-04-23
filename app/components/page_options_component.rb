# frozen_string_literal: true

class PageOptionsComponent < ViewComponent::Base
  attr_reader :pagy, :direction, :turbo_frame, :order_options

  def initialize(pagy, direction: "right", turbo_frame: "_top", order: {})
    @pagy          = pagy
    @direction     = direction
    @turbo_frame   = turbo_frame
    @order_options = order.stringify_keys
    super()
  end

  def order_url(key, direction = :asc)
    new_params = params.slice(:search).permit!
    new_params[:order] = direction == :asc ? key : "-#{key}"
    helpers.url_for(new_params)
  end

  def items_url(items)
    new_params = params.slice(:search, :order).permit!
    new_params[:items] = items
    helpers.url_for(new_params)
  end

  delegate :current_order_key, :current_order_direction, to: :helpers

  def current_order_label
    label = order_options.fetch(current_order_key, "défaut")
    label += " (desc.)" if current_order_direction == :desc
    label
  end

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
