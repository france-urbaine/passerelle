# frozen_string_literal: true

class IndexOptionsComponent < ViewComponent::Base
  attr_reader :pagy, :singular, :plural, :order_hash

  def initialize(pagy, singular, plural: nil, order: {})
    @pagy       = pagy
    @singular   = singular
    @plural     = plural || singular.pluralize
    @order_hash = order.stringify_keys
  end

  def page_url(page)
    new_params = params.slice(:search, :order).permit!
    new_params[:page] = page
    helpers.url_for(new_params)
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
