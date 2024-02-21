# frozen_string_literal: true

require "rails_helper"
require "models/shared_examples"

RSpec.describe OauthApplication do
  # Doorkeeper
  # ----------------------------------------------------------------------------
  describe "Doorkeeper" do
    it { is_expected.to be_a(Doorkeeper::Orm::ActiveRecord::Mixins::Application) }
  end

  # Associations
  # ----------------------------------------------------------------------------
  describe "associations" do
    it { is_expected.to belong_to(:owner) }
    it { is_expected.to have_many(:transmissions) }
  end

  # Scopes: searches
  # ----------------------------------------------------------------------------
  describe "search scopes" do
    describe ".search" do
      it "searches for applications with all criteria" do
        expect {
          described_class.search("Hello").load
        }.to perform_sql_query(<<~SQL.squish)
          SELECT "oauth_applications".*
          FROM   "oauth_applications"
          WHERE  "oauth_applications"."discarded_at" IS NULL
          AND    (LOWER(UNACCENT("oauth_applications"."name")) LIKE LOWER(UNACCENT('%Hello%')))
        SQL
      end

      it "searches for applications with discarded with all criteria" do
        expect {
          described_class.with_discarded.search("Hello").load
        }.to perform_sql_query(<<~SQL.squish)
          SELECT "oauth_applications".*
          FROM   "oauth_applications"
          WHERE  (LOWER(UNACCENT("oauth_applications"."name")) LIKE LOWER(UNACCENT('%Hello%')))
        SQL
      end

      it "searches for applications by matching name" do
        expect {
          described_class.search(name: "Hello").load
        }.to perform_sql_query(<<~SQL.squish)
          SELECT "oauth_applications".*
          FROM   "oauth_applications"
          WHERE  "oauth_applications"."discarded_at" IS NULL
          AND    (LOWER(UNACCENT("oauth_applications"."name")) LIKE LOWER(UNACCENT('%Hello%')))
        SQL
      end
    end
  end

  # Scopes: orders
  # ----------------------------------------------------------------------------
  describe "order scopes" do
    describe ".order_by_param" do
      it "sorts applications by name" do
        expect {
          described_class.order_by_param("name").load
        }.to perform_sql_query(<<~SQL)
          SELECT   "oauth_applications".*
          FROM     "oauth_applications"
          WHERE    "oauth_applications"."discarded_at" IS NULL
          ORDER BY UNACCENT("oauth_applications"."name") ASC NULLS LAST,
                   "oauth_applications"."created_at" ASC
        SQL
      end

      it "sorts applications by name in reversed order" do
        expect {
          described_class.order_by_param("-name").load
        }.to perform_sql_query(<<~SQL)
          SELECT   "oauth_applications".*
          FROM     "oauth_applications"
          WHERE    "oauth_applications"."discarded_at" IS NULL
          ORDER BY UNACCENT("oauth_applications"."name") DESC NULLS FIRST,
                   "oauth_applications"."created_at" DESC
        SQL
      end
    end

    describe ".order_by_score" do
      it "sorts applications by search score" do
        expect {
          described_class.order_by_score("Hello").load
        }.to perform_sql_query(<<~SQL)
          SELECT   "oauth_applications".*
          FROM     "oauth_applications"
          WHERE    "oauth_applications"."discarded_at" IS NULL
          ORDER BY ts_rank_cd(to_tsvector('french', "oauth_applications"."name"), to_tsquery('french', 'Hello')) DESC,
                   "oauth_applications"."created_at" ASC
        SQL
      end
    end

    describe ".order_by_name" do
      it "sorts applications by name without argument" do
        expect {
          described_class.order_by_name.load
        }.to perform_sql_query(<<~SQL)
          SELECT   "oauth_applications".*
          FROM     "oauth_applications"
          WHERE    "oauth_applications"."discarded_at" IS NULL
          ORDER BY UNACCENT("oauth_applications"."name") ASC NULLS LAST
        SQL
      end

      it "sorts applications by name in ascending order" do
        expect {
          described_class.order_by_name(:asc).load
        }.to perform_sql_query(<<~SQL)
          SELECT   "oauth_applications".*
          FROM     "oauth_applications"
          WHERE    "oauth_applications"."discarded_at" IS NULL
          ORDER BY UNACCENT("oauth_applications"."name") ASC NULLS LAST
        SQL
      end

      it "sorts applications by name in descending order" do
        expect {
          described_class.order_by_name(:desc).load
        }.to perform_sql_query(<<~SQL)
          SELECT   "oauth_applications".*
          FROM     "oauth_applications"
          WHERE    "oauth_applications"."discarded_at" IS NULL
          ORDER BY UNACCENT("oauth_applications"."name") DESC NULLS FIRST
        SQL
      end
    end
  end
end
