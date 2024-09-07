# frozen_string_literal: true

require "rails_helper"

RSpec.describe QueryRecords::Match do
  describe ".match" do
    it "performs a SQL query to partially match a simple String" do
      expect {
        Publisher.match(:name, "Solutions").load
      }.to perform_sql_query(<<~SQL)
        SELECT  "publishers".*
        FROM    "publishers"
        WHERE   (LOWER(UNACCENT("publishers"."name")) LIKE LOWER(UNACCENT('%Solutions%')))
      SQL
    end

    it "escapes special characters from input" do
      expect {
        Publisher.match(:name, "Solutions _% Territoire").load
      }.to perform_sql_query(<<~SQL)
        SELECT  "publishers".*
        FROM    "publishers"
        WHERE   (LOWER(UNACCENT("publishers"."name")) LIKE LOWER(UNACCENT('%Solutions \\_\\% Territoire%')))
      SQL
    end

    it "sanitizes input to prevent SQL injections" do
      expect {
        Publisher.match(:name, "Solutions') OR 1=1--").load
      }.to perform_sql_query(<<~SQL)
        SELECT  "publishers".*
        FROM    "publishers"
        WHERE   (LOWER(UNACCENT("publishers"."name")) LIKE LOWER(UNACCENT('%Solutions'') OR 1=1--%')))
      SQL
    end

    it "performs a SQL query to partially match multiple inputs" do
      expect {
        Publisher.match(:name, %w[Solutions Territoire]).load
      }.to perform_sql_query(<<~SQL)
        SELECT  "publishers".*
        FROM    "publishers"
        WHERE   (     (LOWER(UNACCENT("publishers"."name")) LIKE LOWER(UNACCENT('%Solutions%')))
                  OR  (LOWER(UNACCENT("publishers"."name")) LIKE LOWER(UNACCENT('%Territoire%')))
                )
      SQL
    end

    it "merges search conditions to a scope using strict loading or joins" do
      expect {
        Collectivity.strict_loading.joins(:publisher).match(:name, %w[Basque Bearn]).load
      }.to perform_sql_query(<<~SQL)
        SELECT      "collectivities".*
        FROM        "collectivities"
        INNER JOIN  "publishers" ON "publishers"."id" = "collectivities"."publisher_id"
        WHERE       (     (LOWER(UNACCENT("collectivities"."name")) LIKE LOWER(UNACCENT('%Basque%')))
                      OR  (LOWER(UNACCENT("collectivities"."name")) LIKE LOWER(UNACCENT('%Bearn%')))
                    )
      SQL
    end

    it "raises an error on unknown column" do
      expect {
        Publisher.match(:title, "Solutions").load
      }
        .to raise_error(ArgumentError)
        .and perform_no_sql_queries
    end
  end
end
