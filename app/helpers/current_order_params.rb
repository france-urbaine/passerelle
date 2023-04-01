# frozen_string_literal: true

module CurrentOrderParams
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
