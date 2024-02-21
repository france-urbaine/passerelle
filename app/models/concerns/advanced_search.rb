# frozen_string_literal: true

module AdvancedSearch
  extend ActiveSupport::Concern

  class_methods do
    def advanced_search(input, default: nil, matches: {}, scopes: {})
      return all if input.blank?

      case input
      when String
        _, keys = matches.find { |(regexp, _)| regexp.match?(input) }
        keys ||= default || scopes.keys

        advanced_search_with_input_string(input, scopes.slice(*keys))
      when Hash, ActionController::Parameters
        advanced_search_with_input_hash(input, scopes)
      else
        raise TypeError, "invalid input #{input}"
      end
    end

    def match(attribute, value)
      raise ArgumentError unless column_for_attribute(attribute)

      quoted_column = "#{connection.quote_table_name(table_name)}.#{connection.quote_column_name(attribute)}"

      where(
        "LOWER(UNACCENT(#{quoted_column})) LIKE LOWER(UNACCENT(?))",
        "%#{sanitize_sql_like(value)}%"
      )
    end

    def match_enum(attribute, value, i81n_path:)
      enum_keys = I18n.t(i81n_path, raise: true)
      value     = I18n.transliterate(value).downcase.squish

      enum_keys = enum_keys
        .select { |_, label| I18n.transliterate(label).downcase.include?(value) }
        .keys

      if enum_keys.any?
        where(attribute => enum_keys)
      else
        none
      end
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

      return none if wheres.all?(&:null_relation?)

      combined = merge(wheres.reject(&:null_relation?).reduce(:or))
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
