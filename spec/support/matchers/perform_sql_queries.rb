# frozen_string_literal: true

module Matchers
  module PerformSQLQueries
    extend RSpec::Matchers::DSL

    def perform_sql_query(query)
      perform_sql_queries.including(query)
    end

    matcher :perform_no_sql_queries do
      supports_block_expectations
      include CaptureSQLQueries

      match do |actual|
        @actual_queries = capture_sql_queries(&actual)
        @actual_queries.empty?
      end
    end

    matcher :perform_sql_queries do
      supports_block_expectations
      include CaptureSQLQueries

      chain :including do |query|
        # https://rubular.com/r/7l4NUpa8HwBbfR
        (@expected_queries ||= []) << query.squish.gsub(/((?<=\()\s+|\s+(?=\)))/, "")
      end

      chain :to_the_number_of do |expected|
        @expected_number_of_queries = expected
      end

      match do |actual|
        @actual_queries = capture_sql_queries(&actual)

        @actual_queries.any? &&
          number_of_queries_match? &&
          expected_queries_match?
      end

      def number_of_queries_match?
        @expected_number_of_queries.nil? || @expected_number_of_queries == @actual_queries.size
      end

      def expected_queries_match?
        @expected_queries.nil? || @expected_queries.all? { |query| @actual_queries.include?(query) }
      end
    end

    module CaptureSQLQueries
      def capture_sql_queries(&)
        sql_queries = []
        subscriber  = ActiveSupport::Notifications.subscribe("sql.active_record") do |_, _, _, _, payload|
          next if payload[:sql].match?(/FROM (pg_class|pg_attribute|pg_index)/)

          sql_queries << payload[:sql].squish.gsub(/((?<=\()\s+|\s+(?=\)))/, "")
        end

        ActiveRecord::Base.connection.unprepared_statement(&)

        sql_queries
      ensure
        ActiveSupport::Notifications.unsubscribe(subscriber)
      end

      def failure_message
        diff_queries(super)
      end

      def diff_queries(message)
        ::RSpec::Matchers::MultiMatcherDiff.from(
          @expected_queries || [],
          @actual_queries
        ).message_with_diff(
          message,
          RSpec::Expectations.differ
        )
      end
    end
  end
end
