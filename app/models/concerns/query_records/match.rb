# frozen_string_literal: true

module QueryRecords
  module Match
    extend ActiveSupport::Concern

    class_methods do
      def match(attribute, input)
        column = column_for_attribute(attribute)
        raise ArgumentError if column.is_a?(ActiveRecord::ConnectionAdapters::NullColumn)

        quoted_column = "#{connection.quote_table_name(table_name)}.#{connection.quote_column_name(attribute)}"

        wheres = Array.wrap(input).map do |value|
          unscoped.where(
            "LOWER(UNACCENT(#{quoted_column})) LIKE LOWER(UNACCENT(?))",
            "%#{sanitize_sql_like(value)}%"
          )
        end

        merge(wheres.reduce(:or))
      end
    end
  end
end
