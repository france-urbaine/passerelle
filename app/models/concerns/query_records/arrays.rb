# frozen_string_literal: true

module QueryRecords
  module Arrays
    extend ActiveSupport::Concern

    class_methods do
      def search_in_array(attribute, value)
        column = column_for_attribute(attribute)
        raise ArgumentError if column.is_a?(ActiveRecord::ConnectionAdapters::NullColumn) || !column.array?

        quoted_column = "#{connection.quote_table_name(table_name)}.#{connection.quote_column_name(attribute)}"
        sql_type      = column.sql_type

        if value.is_a?(ActiveRecord::Relation)
          where("#{quoted_column} && (?)", apply_array_agg_sql_function(value, sql_type))
        elsif value.blank?
          where(attribute => nil)
        else
          values = Array.wrap(value)

          if values.size == 1
            where(%{? = ANY (#{quoted_column})}, *values)
          else
            # Sanitize is useless but tells brakeman its safe from SQL injection
            sql = sanitize_sql([
              "#{quoted_column} && #{prepare_sql_array_replacements(values.size, sql_type)}",
              *values
            ])

            where(sql)
          end
        end
      end

      def apply_array_agg_sql_function(relation, sql_type = nil)
        return relation unless relation.select_values.size == 1

        select_value = relation.select_values[0]
        return relation if select_value.match?(/array_agg\([^)+]\)/)

        column = relation.column_for_attribute(select_value)
        return relation if column.is_a?(ActiveRecord::ConnectionAdapters::NullColumn)
        return relation if sql_type && sql_type != column.sql_type

        table_name    = relation.table_name
        quoted_column = "#{connection.quote_table_name(table_name)}.#{connection.quote_column_name(select_value)}"

        relation.unscope(:select).select("array_agg(#{quoted_column})")
      end

      def prepare_sql_array_replacements(size, sql_type = nil)
        raise ArgumentsError unless size.is_a?(Integer)

        replacement = "?"
        replacement = "?::#{sql_type}" if sql_type

        sql = "ARRAY["
        sql += Array.new(size, replacement).join(", ")
        sql += "]"

        sanitize_sql(sql)
      end
    end
  end
end
