# frozen_string_literal: true

require "rails_helper"

RSpec.describe QueryRecords::Arrays do
  describe ".search_in_array" do
    it "performs a SQL query to match a single string" do
      expect {
        Report.search_in_array(:anomalies, "consistance").load
      }.to perform_sql_query(<<~SQL)
        SELECT "reports".*
        FROM   "reports"
        WHERE  ('consistance' = ANY ("reports"."anomalies"))
      SQL
    end

    it "performs a SQL query to match multiple values" do
      expect {
        Report.search_in_array(:anomalies, %w[consistance affectation]).load
      }.to perform_sql_query(<<~SQL)
        SELECT "reports".*
        FROM   "reports"
        WHERE  ("reports"."anomalies" && ARRAY['consistance'::anomaly, 'affectation'::anomaly])
      SQL
    end

    it "performs a SQL query to match values from a subquery" do
      expect {
        Office.search_in_array(
          :competences,
          Report.where(state: "transmitted").select(:form_type)
        ).load
      }.to perform_sql_query(<<~SQL)
        SELECT  "offices".*
        FROM    "offices"
        WHERE   ("offices"."competences" && (
                  SELECT array_agg("reports"."form_type")
                  FROM   "reports"
                  WHERE  "reports"."state" = 'transmitted'
                ))
      SQL
    end

    it "performs a SQL query to match values from a subquery where array_agg is already called" do
      expect {
        Office.search_in_array(
          :competences,
          Report.where(state: "transmitted").select(Arel.sql("array_agg(form_type)"))
        ).load
      }.to perform_sql_query(<<~SQL)
        SELECT  "offices".*
        FROM    "offices"
        WHERE   ("offices"."competences" && (
                  SELECT array_agg(form_type)
                  FROM   "reports"
                  WHERE  "reports"."state" = 'transmitted'
                ))
      SQL
    end

    it "sanitizes input to prevent SQL injections" do
      expect {
        Report.search_in_array(:anomalies, "consistance') OR 1=1--").load
      }
        .to raise_error(ActiveRecord::StatementInvalid)
        .and perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  ('consistance'') OR 1=1--' = ANY ("reports"."anomalies"))
        SQL
    end

    it "raises an error on unknown column" do
      expect {
        Report.search_in_array(:anomaly, "consistance").load
      }
        .to raise_error(ArgumentError)
        .and perform_no_sql_queries
    end

    it "raises an error when column is not an Array" do
      expect {
        Report.search_in_array(:form_type, "consistance").load
      }
        .to raise_error(ArgumentError)
        .and perform_no_sql_queries
    end

    it "raises an error on invalid values" do
      expect {
        Report.search_in_array(:anomalies, "consistancy").load
      }
        .to raise_error(ActiveRecord::StatementInvalid)
        .and perform_sql_query(<<~SQL)
          SELECT "reports".*
          FROM   "reports"
          WHERE  ('consistancy' = ANY ("reports"."anomalies"))
        SQL
    end

    it "raises an error when passing a subquery without proper selected attribute" do
      expect {
        Office.search_in_array(
          :competences,
          Report.where(state: "transmitted")
        ).load
      }
        .to raise_error(ActiveRecord::StatementInvalid)
        .and perform_sql_query(<<~SQL)
          SELECT  "offices".*
          FROM    "offices"
          WHERE   ("offices"."competences" && (
                    SELECT "reports".*
                    FROM   "reports"
                    WHERE  "reports"."state" = 'transmitted'
                  ))
        SQL
    end
  end
end
