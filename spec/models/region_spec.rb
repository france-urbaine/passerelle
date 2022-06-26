# frozen_string_literal: true

require "rails_helper"

RSpec.describe Region, type: :model do
  # Associations
  # ----------------------------------------------------------------------------
  it { is_expected.to have_many(:departements) }
  it { is_expected.to have_many(:communes) }
  it { is_expected.to have_many(:epcis) }
  it { is_expected.to have_many(:ddfips) }
  it { is_expected.to have_one(:registered_collectivity) }
  it { is_expected.to respond_to(:on_territory_collectivities) }

  # Validations
  # ----------------------------------------------------------------------------
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:code_region) }

  it { is_expected.to     allow_value("12")  .for(:code_region) }
  it { is_expected.not_to allow_value("12AB").for(:code_region) }

  context "with an existing region" do
    before { create(:region) }

    it { is_expected.to validate_uniqueness_of(:code_region).case_insensitive }
  end

  # Search
  # ----------------------------------------------------------------------------
  describe ".search" do
    it do
      expect {
        described_class.search(name: "Hello").load
      }.to perform_sql_query(<<~SQL)
        SELECT "regions".*
        FROM   "regions"
        WHERE  (LOWER(UNACCENT("regions"."name")) LIKE LOWER(UNACCENT('%Hello%')))
      SQL
    end

    it do
      expect {
        described_class.search("Hello").load
      }.to perform_sql_query(<<~SQL)
        SELECT "regions".*
        FROM   "regions"
        WHERE (LOWER(UNACCENT("regions"."name")) LIKE LOWER(UNACCENT('%Hello%'))
          OR "regions"."code_region" = 'Hello')
      SQL
    end
  end

  describe ".order_by_score" do
    it do
      expect {
        described_class.order_by_score("Hello").load
      }.to perform_sql_query(<<~SQL)
        SELECT "regions".*
        FROM   "regions"
        ORDER BY
          ts_rank_cd(to_tsvector('french', "regions"."name"), to_tsquery('french', 'Hello')) DESC,
          "regions"."code_region" ASC
      SQL
    end
  end

  # Other associations
  # ----------------------------------------------------------------------------
  describe "on_territory_collectivities" do
    let(:region) { create(:region) }

    it do
      expect {
        region.on_territory_collectivities.load
      }.to perform_sql_query(<<~SQL)
        SELECT "collectivities".*
        FROM   "collectivities"
        WHERE  "collectivities"."discarded_at" IS NULL
          AND (
                "collectivities"."territory_type" = 'Departement'
            AND "collectivities"."territory_id" IN (
                  SELECT "departements"."id"
                  FROM "departements"
                  WHERE "departements"."code_region" = '#{region.code_region}'
            )
            OR  "collectivities"."territory_type" = 'Commune'
            AND "collectivities"."territory_id" IN (
                  SELECT "communes"."id"
                  FROM "communes"
                  INNER JOIN "departements" ON "communes"."code_departement" = "departements"."code_departement"
                  WHERE "departements"."code_region" = '#{region.code_region}'
            )
            OR  "collectivities"."territory_type" = 'EPCI'
            AND "collectivities"."territory_id" IN (
                  SELECT "epcis"."id"
                  FROM "epcis"
                  INNER JOIN "communes" ON "communes"."siren_epci" = "epcis"."siren"
                  INNER JOIN "departements" ON "communes"."code_departement" = "departements"."code_departement"
                  WHERE "departements"."code_region" = '#{region.code_region}'
            )
          )
      SQL
    end
  end

  # Counters
  # ----------------------------------------------------------------------------
  describe ".reset_all_counters" do
    it do
      expect {
        described_class.reset_all_counters
      }.to perform_sql_query(<<~SQL)
        UPDATE "regions"
        SET "departements_count" = (
              SELECT COUNT(*)
              FROM "departements"
              WHERE ("departements"."code_region" = "regions"."code_region")
            ),
            "epcis_count" = (
              SELECT COUNT(*)
              FROM "epcis"
              INNER JOIN "departements" ON "departements"."code_departement" = "epcis"."code_departement"
              WHERE ("departements"."code_region" = "regions"."code_region")
            ),
            "communes_count" = (
              SELECT COUNT(*)
              FROM "communes"
              INNER JOIN "departements" ON "departements"."code_departement" = "communes"."code_departement"
              WHERE ("departements"."code_region" = "regions"."code_region")
            ),
            "ddfips_count" = (
              SELECT COUNT(*)
              FROM "ddfips"
              INNER JOIN "departements" ON "departements"."code_departement" = "ddfips"."code_departement"
              WHERE ("departements"."code_region" = "regions"."code_region")
            ),
            "collectivities_count" = (
              SELECT COUNT(*)
              FROM  "collectivities"
              WHERE "collectivities"."discarded_at" IS NULL
                AND (
                      "collectivities"."territory_type" = 'Commune'
                  AND "collectivities"."territory_id" IN (
                        SELECT "communes"."id"
                        FROM "communes"
                        INNER JOIN "departements" ON "departements"."code_departement" = "communes"."code_departement"
                        WHERE ("departements"."code_region" = "regions"."code_region")
                  )
                  OR  "collectivities"."territory_type" = 'EPCI'
                  AND "collectivities"."territory_id" IN (
                        SELECT "epcis"."id"
                        FROM "epcis"
                        INNER JOIN "communes" ON "communes"."siren_epci" = "epcis"."siren"
                        INNER JOIN "departements" ON "departements"."code_departement" = "communes"."code_departement"
                        WHERE ("departements"."code_region" = "regions"."code_region")
                  )
                  OR  "collectivities"."territory_type" = 'Departement'
                  AND "collectivities"."territory_id" IN (
                        SELECT "departements"."id"
                        FROM   "departements"
                        WHERE ("departements"."code_region" = "regions"."code_region")
                  )
                )
            )
      SQL
    end
  end
end
