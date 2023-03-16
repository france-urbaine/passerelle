# frozen_string_literal: true

module ControllerOrder
  extend ActiveSupport::Concern

  def order(relation)
    relation = relation.order_by_param(params[:order]) if params[:order].present?
    relation = relation.order_by_score(params[:search]) if params[:search].present?
    relation = relation.order(relation.implicit_order_column) if relation.respond_to?(:implicit_order_column)
    relation
  end
end
