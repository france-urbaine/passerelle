# frozen_string_literal: true

module AdvancedSearch
  extend ActiveSupport::Concern

  # https://rubular.com/r/6BGs42O3MszcPf
  MULTIPLE_CRITERIA_REGEXP = /
    (?<key>(?<=^|\s)[[:alpha:]0-9\-_]+)
    :
    (?:\()?(?<value>((?<!\()[^\s]+|(?<=\()[^)]+(?=\))))(?:\))?
  /xi

  class_methods do
    def advanced_search(input, default: nil, matches: {}, scopes: {})
      return all if input.blank?

      string, hash = parse_advanced_search_input(input)

      relations = [all]
      relations << advanced_search_relation_from_input_string(string, scopes, matches, default) if string.present?
      relations << advanced_search_relation_from_input_hash(hash, scopes) if hash.present?

      combine_advanced_search_relations(relations, :and)
    end

    def parse_advanced_search_input(input)
      case input
      when String
        hash   = input.scan(MULTIPLE_CRITERIA_REGEXP).to_h
        string = input.gsub(MULTIPLE_CRITERIA_REGEXP, "").squish

        hash.transform_values! do |v|
          v.include?(",") ? v.split(",").map(&:strip) : v
        end
      when Hash
        hash = input.stringify_keys
      when ActionController::Parameters
        hash = input.to_unsafe_h
      else
        raise TypeError, "invalid input #{input}"
      end

      [string, hash]
    end

    def flatten_advanced_search_input(string, hash)
      return string || "" if hash.blank?

      output = hash.map do |(k, v)|
        v = v.join(",") if v.is_a?(Array)
        v = "(#{v})"    if v.include?(",") || v.include?(" ")
        "#{k}:#{v}"
      end

      output << string if string.present?
      output.join(" ")
    end

    private

    def advanced_search_relation_from_input_string(input, scopes, matches, default_keys)
      _, keys = matches.find { |(regexp, _)| regexp.match?(input) }

      keys ||= default_keys if default_keys
      keys ||= scopes.keys

      scopes    = scopes.slice(*keys)
      relations = scopes.map do |(_, scope)|
        unscoped.instance_exec(input, &scope)
      end

      combine_advanced_search_relations(relations, :or)
    end

    def advanced_search_relation_from_input_hash(input, scopes)
      input     = input.stringify_keys
      scopes    = scopes.stringify_keys

      relations = scopes.filter_map do |key, scope|
        unscoped.instance_exec(input[key], &scope) if input.key?(key)
      end

      combine_advanced_search_relations(relations, :and)
    end

    def combine_advanced_search_relations(relations, operator)
      relations = exclude_advanced_search_null_relations(relations, operator)
      return none if relations.empty?

      strict_loading = false
      joins  = []
      wheres = []

      relations.each do |relation|
        if relation.left_outer_joins_values.any?
          joins << relation.left_outer_joins_values
          relation = relation.unscope(:left_outer_joins)
        end

        strict_loading = true if relation.strict_loading_value
        relation = relation.strict_loading(false)

        wheres << relation
      end

      combined = unscoped.merge(wheres.reduce(operator))
      combined = combined.left_joins(*joins) if joins.any?
      combined.strict_loading(strict_loading)
      combined
    end

    def exclude_advanced_search_null_relations(relations, operator)
      case operator
      when :or
        relations.reject(&:null_relation?)
      when :and
        relations.any?(&:null_relation?) ? [] : relations
      else
        raise ArgumentError, "invalid operator: #{operator.inspect}"
      end
    end
  end
end
