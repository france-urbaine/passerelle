# frozen_string_literal: true

module ControllerAutocompletion
  private

  def autocomplete_collection(relation)
    relation = relation.autocomplete(params[:q]) if params[:q]
    relation = order_collection(relation)
    relation = relation.limit(50)
    relation.to_a
  end

  def merge_autocomplete_collections(*relations)
    relations.inject([]) do |memo, relation|
      break memo if memo.size >= 50

      relation = relation.autocomplete(params[:q]) if params[:q]
      relation = order_collection(relation)
      relation = relation.limit(50 - memo.size)

      memo + relation.to_a
    end
  end
end
