# frozen_string_literal: true

module AdvancedOrder
  extend ActiveSupport::Concern

  class_methods do
    def advanced_order(input, scopes)
      input    = input.to_s
      scopes   = scopes.stringify_keys
      relation = all

      if input.start_with?("-")
        order_name = input[1..]
        direction  = :desc
      else
        order_name = input
        direction  = :asc
      end

      scope = scopes[order_name]

      relation = relation.instance_exec(direction, &scope) if scope
      relation = relation.order(arel_table[implicit_order_column].send(direction)) if implicit_order_column
      relation
    end

    def unaccent_order(column, direction)
      desc   = direction.to_s == "desc"
      column = %("#{table_name}"."#{column}") unless column.is_a?(String)

      sql  = "UNACCENT(#{column})"
      sql += desc ? " DESC" : " ASC"
      sql += desc ? " NULLS FIRST" : " NULLS LAST"

      order(Arel.sql(sql))
    end
  end
end
