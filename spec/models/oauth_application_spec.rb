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
  end

  # Scopes
  # ----------------------------------------------------------------------------
  describe "scopes" do
    describe ".search" do
      it "searches for OauthApplications with all criteria" do
        expect {
          described_class.search("Hello").load
        }.to perform_sql_query(<<~SQL.squish)
          SELECT "oauth_applications".*
          FROM   "oauth_applications"
          WHERE  "oauth_applications"."discarded_at" IS NULL
          AND    (LOWER(UNACCENT("oauth_applications"."name")) LIKE LOWER(UNACCENT('%Hello%')))
        SQL
      end

      it "searches for OauthApplications with discarded with all criteria" do
        expect {
          described_class.with_discarded.search("Hello").load
        }.to perform_sql_query(<<~SQL.squish)
          SELECT "oauth_applications".*
          FROM   "oauth_applications"
          WHERE  (LOWER(UNACCENT("oauth_applications"."name")) LIKE LOWER(UNACCENT('%Hello%')))
        SQL
      end

      it "searches for OauthApplications by matching name" do
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

    describe ".order_by_param" do
      it "orders OauthApplications by name" do
        expect {
          described_class.order_by_param("name").load
        }.to perform_sql_query(<<~SQL)
          SELECT   "oauth_applications".*
          FROM     "oauth_applications"
          WHERE    "oauth_applications"."discarded_at" IS NULL
          ORDER BY UNACCENT("oauth_applications"."name") ASC,
                   "oauth_applications"."created_at" ASC
        SQL
      end

      it "orders OauthApplications by name in descendant order" do
        expect {
          described_class.order_by_param("-name").load
        }.to perform_sql_query(<<~SQL)
          SELECT   "oauth_applications".*
          FROM     "oauth_applications"
          WHERE    "oauth_applications"."discarded_at" IS NULL
          ORDER BY UNACCENT("oauth_applications"."name") DESC,
                   "oauth_applications"."created_at" DESC
        SQL
      end
    end

    describe ".order_by_score" do
      it "orders OauthApplications by search score" do
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
  end
end
