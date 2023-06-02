# frozen_string_literal: true

module Matchers
  module PerformSQLQueries
    extend RSpec::Matchers::DSL

    def perform_sql_query(expected)
      perform_sql_queries.including(expected)
    end

    def perform_no_sql_query
      perform_sql_queries.to_the_number_of(0)
    end

    matcher :perform_sql_queries do
      supports_block_expectations

      chain :including do |expected|
        # https://rubular.com/r/7l4NUpa8HwBbfR
        @expected_queries ||= []
        @expected_queries << expected.squish.gsub(/((?<=\()\s+|\s+(?=\)))/, "")
      end

      chain :to_the_number_of do |expected|
        @expected_number_of_queries = expected
      end

      match do |actual|
        @actual_queries = capture_sql_queries(&actual)

        if @expected_number_of_queries&.zero?
          @actual_queries.empty?
        else
          @actual_queries.any? &&
            number_of_queries_match? &&
            expected_queries_match?
        end
      end

      def failure_message
        message = super
        message = diff_queries(message) if @expected_queries
        message
      end

      def capture_sql_queries(&)
        sql_queries = []
        subscriber  = ActiveSupport::Notifications.subscribe("sql.active_record") do |_, _, _, _, payload|
          sql_queries << payload[:sql]
        end

        ActiveRecord::Base.connection.unprepared_statement(&)

        sql_queries
      ensure
        ActiveSupport::Notifications.unsubscribe(subscriber)
      end

      def number_of_queries_match?
        @expected_number_of_queries.nil? || @expected_number_of_queries == @actual_queries.size
      end

      def expected_queries_match?
        @expected_queries.nil? || @expected_queries.all? { |query| @actual_queries.include?(query) }
      end

      def diff_queries(message)
        ::RSpec::Matchers::ExpectedsForMultipleDiffs.from(@expected_queries).message_with_diff(
          message,
          RSpec::Expectations.differ,
          @actual_queries
        )
      end
    end
  end
end
