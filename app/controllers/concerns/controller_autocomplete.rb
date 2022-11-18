# frozen_string_literal: true

module ControllerAutocomplete
  extend ActiveSupport::Concern

  def autocomplete(relation)
    input = params[:q]
    relation.search(input)
      .order_by_score(input)
      .order(relation.implicit_order_column)
      .limit(50)
  end
end
