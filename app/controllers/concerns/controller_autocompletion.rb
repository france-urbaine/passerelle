# frozen_string_literal: true

module ControllerAutocompletion
  private

  def merge_autocomplete_collections(*relations)
    relations.inject([]) do |memo, relation|
      break memo if memo.size >= 50

      relation = search_collection(relation)
      relation = order_collection(relation)
      relation = relation.limit(50 - memo.size)

      memo + relation.to_a
    end
  end
end
