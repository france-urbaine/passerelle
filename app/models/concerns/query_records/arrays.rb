# frozen_string_literal: true

module QueryRecords
  module Arrays
    extend ActiveSupport::Concern

    class_methods do
      def search_in_array(attribute, value)
        column = column_for_attribute(attribute)
        raise ArgumentError unless column.array?

        quoted_column = "#{connection.quote_table_name(table_name)}.#{connection.quote_column_name(attribute)}"

        if value.is_a?(ActiveRecord::Relation)
          select = value.select_values[0] if value.select_values.size == 1

          if select && value.column_for_attribute(select).sql_type == column.sql_type
            select = "#{connection.quote_table_name(value.table_name)}.#{connection.quote_column_name(select)}"
            value  = value.unscope(:select).select("array_agg(#{select})")
          end

          where("#{quoted_column} && (?)", value)
        elsif value.blank?
          where(attribute => nil)
        else
          values = Array.wrap(value)

          if values.size == 1
            where(%{? = ANY (#{quoted_column})}, *values)
          else
            sql  = "#{quoted_column} && ARRAY["
            sql += Array.new(values.size, "?::#{column.sql_type}").join(", ")
            sql += "]"

            sql = sanitize_sql([sql, *values])

            where(sql)
          end
        end
      end
    end
  end
end
