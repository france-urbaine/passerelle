# frozen_string_literal: true

module AdvancedSearch
  extend ActiveSupport::Concern

  class_methods do
    def advanced_search(input, scopes)
      return all if input.blank?

      case input
      when String
        advanced_search_with_input_string(input, scopes)
      when Hash, ActionController::Parameters
        advanced_search_with_input_hash(input, scopes)
      else
        raise TypeError, "invalid input #{input}"
      end
    end

    def match(attribute, value)
      raise ArgumentError unless column_for_attribute(attribute)

      where(
        "LOWER(UNACCENT(\"#{table_name}\".\"#{attribute}\")) LIKE LOWER(UNACCENT(?))",
        "%#{sanitize_sql_like(value)}%"
      )
    end

    private

    def advanced_search_with_input_string(input, scopes)
      joins  = []
      wheres = []

      scopes.each_value do |scope|
        relation = unscoped.instance_exec(input, &scope)

        if relation.left_outer_joins_values.any?
          joins << relation.left_outer_joins_values
          relation = relation.unscope(:left_outer_joins)
        end

        wheres << relation
      end

      combined = merge(wheres.reduce(:or))
      combined = combined.left_joins(*joins) if joins.any?
      combined
    end

    def advanced_search_with_input_hash(input, scopes)
      input  = input.stringify_keys
      scopes = scopes.stringify_keys

      wheres = scopes.filter_map do |key, scope|
        instance_exec(input[key], &scope) if input.key?(key)
      end

      wheres.any? ? merge(wheres.reduce(:or)) : none
    end
  end
end
