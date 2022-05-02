# frozen_string_literal: true

require "rails_helper"

RSpec.describe Departement, type: :model do
  # Associations
  # ----------------------------------------------------------------------------
  it { is_expected.to belong_to(:region) }
  it { is_expected.to have_many(:communes) }
  it { is_expected.to have_many(:epcis) }
  it { is_expected.to have_many(:ddfips) }
  it { is_expected.to have_one(:registered_collectivity) }
  it { is_expected.to respond_to(:on_territory_collectivities) }

  # Validations
  # ----------------------------------------------------------------------------
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:code_departement) }
  it { is_expected.to validate_presence_of(:code_region) }

  it { is_expected.to     allow_value("01") .for(:code_departement) }
  it { is_expected.to     allow_value("2A") .for(:code_departement) }
  it { is_expected.to     allow_value("987").for(:code_departement) }
  it { is_expected.not_to allow_value("1")  .for(:code_departement) }
  it { is_expected.not_to allow_value("123").for(:code_departement) }
  it { is_expected.not_to allow_value("3C") .for(:code_departement) }

  it { is_expected.to     allow_value("12")  .for(:code_region) }
  it { is_expected.not_to allow_value("12AB").for(:code_region) }

  # Search scope
  # ----------------------------------------------------------------------------
  describe ".search" do
    it do
      expect {
        described_class.search(name: "Hello").load
      }.to perform_sql_query(<<~SQL)
        SELECT "departements".*
        FROM   "departements"
        WHERE  (LOWER(UNACCENT("departements"."name")) LIKE LOWER(UNACCENT('%Hello%')))
      SQL
    end

    it do
      expect {
        described_class.search("Hello").load
      }.to perform_sql_query(<<~SQL)
        SELECT "departements".*
        FROM   "departements"
        LEFT OUTER JOIN "regions" ON "regions"."code_region" = "departements"."code_region"
        WHERE (LOWER(UNACCENT("departements"."name")) LIKE LOWER(UNACCENT('%Hello%'))
          OR "departements"."code_departement" = 'Hello'
          OR LOWER(UNACCENT(\"regions\".\"name\")) LIKE LOWER(UNACCENT('%Hello%')))
      SQL
    end
  end

  # Order scope
  # ----------------------------------------------------------------------------
  describe ".order_by_param" do
    it do
      expect {
        described_class.order_by_param("departement").load
      }.to perform_sql_query(<<~SQL)
        SELECT "departements".*
        FROM   "departements"
        ORDER BY "departements"."code_departement" ASC
      SQL
    end

    it do
      expect {
        described_class.order_by_param("-departement").load
      }.to perform_sql_query(<<~SQL)
        SELECT "departements".*
        FROM   "departements"
        ORDER BY "departements"."code_departement" DESC
      SQL
    end
  end

  describe ".order_by_score" do
    it do
      expect {
        described_class.order_by_score("Hello").load
      }.to perform_sql_query(<<~SQL)
        SELECT "departements".*
        FROM   "departements"
        ORDER BY ts_rank_cd(to_tsvector('french', "departements"."name"), to_tsquery('french', 'Hello')) DESC,
                 "departements"."code_departement" ASC
      SQL
    end
  end

  # Other associations
  # ----------------------------------------------------------------------------
  describe "#on_territory_collectivities" do
    let(:departement) { create(:departement) }

    it do
      expect {
        departement.on_territory_collectivities.load
      }.to perform_sql_query(<<~SQL)
        SELECT "collectivities".*
        FROM   "collectivities"
        WHERE  "collectivities"."discarded_at" IS NULL
          AND (
                "collectivities"."territory_type" = 'Departement'
            AND "collectivities"."territory_id"   = '#{departement.id}'
            OR  "collectivities"."territory_type" = 'Commune'
            AND "collectivities"."territory_id" IN (
                  SELECT "communes"."id"
                  FROM "communes"
                  WHERE "communes"."code_departement" = '#{departement.code_departement}'
            )
            OR  "collectivities"."territory_type" = 'EPCI'
            AND "collectivities"."territory_id" IN (
                  SELECT "epcis"."id"
                  FROM "epcis"
                  INNER JOIN "communes" ON "communes"."siren_epci" = "epcis"."siren"
                  WHERE "communes"."code_departement" = '#{departement.code_departement}'
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
        UPDATE "departements"
        SET "epcis_count" = (
              SELECT COUNT(*)
              FROM "epcis"
              WHERE ("epcis"."code_departement" = "departements"."code_departement")
            ),
            "communes_count" = (
              SELECT COUNT(*)
              FROM "communes"
              WHERE ("communes"."code_departement" = "departements"."code_departement")
            ),
            "ddfips_count" = (
              SELECT COUNT(*)
              FROM "ddfips"
              WHERE ("ddfips"."code_departement" = "departements"."code_departement")
            ),
            "collectivities_count" = (
              SELECT COUNT(*)
              FROM   "collectivities"
              WHERE  "collectivities"."discarded_at" IS NULL
                AND (
                      "collectivities"."territory_type" = 'Departement'
                  AND "collectivities"."territory_id"   = "departements"."id"
                  OR  "collectivities"."territory_type" = 'Commune'
                  AND "collectivities"."territory_id" IN (
                        SELECT "communes"."id"
                        FROM "communes"
                        WHERE ("communes"."code_departement" = "departements"."code_departement")
                  )
                  OR  "collectivities"."territory_type" = 'EPCI'
                  AND "collectivities"."territory_id" IN (
                        SELECT "epcis"."id"
                        FROM "epcis"
                        INNER JOIN "communes" ON "communes"."siren_epci" = "epcis"."siren"
                        WHERE ("communes"."code_departement" = "departements"."code_departement")
                  )
                )
            )
      SQL
    end
  end
end
