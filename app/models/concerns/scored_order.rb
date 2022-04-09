# frozen_string_literal: true

module ScoredOrder
  extend ActiveSupport::Concern

  class_methods do
    def scored_order(column, input)
      ts_rank = Arel.sql(sanitize_sql([
        "ts_rank_cd(to_tsvector('french', \"#{table_name}\".\"#{column}\"), to_tsquery('french', ?))",
        input.delete("'()|&!:><").split.join(" | ")
      ]))

      order(ts_rank => :desc).order(implicit_order_column)
    end
  end
end
