# frozen_string_literal: true

module ControllerOrder
  extend ActiveSupport::Concern

  included do
    helper_method :current_order, :current_order_key, :current_order_direction
  end

  def current_order
    return @current_order if defined?(@current_order)

    @current_order = params[:order].presence
  end

  def current_order_key
    return @current_order_key if defined?(@current_order_key)

    @current_order_key = current_order&.slice(/^^-?(.+)$/, 1)
  end

  def current_order_direction
    return @current_order_direction if defined?(@current_order_direction)

    @current_order_direction = current_order && (current_order[0] == "-" ? :desc : :asc)
  end

  def order(relation)
    relation = relation.order_by_param(params[:order]) if params[:order].present?
    relation = relation.order_by_score(params[:search]) if params[:search].present?
    relation = relation.order(relation.implicit_order_column) if relation.respond_to?(:implicit_order_column)
    relation
  end
end
