# frozen_string_literal: true

module ResetCounters
  extend ActiveSupport::Concern

  def reset_all_counters
    self.class.where(id: id).reset_all_counters
  end

  class_methods do
    def reset_all_counters
      counters = column_names.select { |s| s.end_with?("_count") }
                             .map    { |s| s.delete_suffix("_count").to_sym }
                             .select { |s| reflect_on_association(s) }

      return if counters.empty?

      select(:id).find_each do |record|
        reset_counters record.id, *counters
      end
    end

    private

    def update_all_counters(subqueries)
      setters = subqueries.map do |attribute, query|
        query = query.select("COUNT(*)").to_sql

        "\"#{attribute}\" = (#{query})"
      end

      update_all(setters.join(", ").squish)
    end
  end
end
