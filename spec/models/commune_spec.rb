# frozen_string_literal: true

require "rails_helper"

RSpec.describe Commune, type: :model do
  # Associations
  # ----------------------------------------------------------------------------
  it { is_expected.to belong_to(:departement).required }
  it { is_expected.to belong_to(:epci).optional }
  it { is_expected.to have_one(:registered_collectivity) }
  it { is_expected.to respond_to(:on_territory_collectivities) }

  # Validations
  # ----------------------------------------------------------------------------
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:code_insee) }
  it { is_expected.to validate_presence_of(:code_departement) }
  it { is_expected.not_to validate_presence_of(:siren_epci) }

  it { is_expected.to     allow_value("64102").for(:code_insee) }
  it { is_expected.to     allow_value("2A013").for(:code_insee) }
  it { is_expected.to     allow_value("97102").for(:code_insee) }
  it { is_expected.not_to allow_value("1A674").for(:code_insee) }
  it { is_expected.not_to allow_value("123456").for(:code_insee) }

  it { is_expected.to     allow_value("01").for(:code_departement) }
  it { is_expected.to     allow_value("2A").for(:code_departement) }
  it { is_expected.to     allow_value("987").for(:code_departement) }
  it { is_expected.not_to allow_value("1").for(:code_departement) }
  it { is_expected.not_to allow_value("123").for(:code_departement) }
  it { is_expected.not_to allow_value("3C").for(:code_departement) }

  it { is_expected.to     allow_value("801453893").for(:siren_epci) }
  it { is_expected.not_to allow_value("1234567AB").for(:siren_epci) }
  it { is_expected.not_to allow_value("1234567891").for(:siren_epci) }

  # Formatting before save
  # ----------------------------------------------------------------------------
  it { expect(create(:commune, siren_epci: "")).to have_attributes(siren_epci: nil) }

  # Search scope
  # ----------------------------------------------------------------------------
  describe ".search" do
    it do
      expect{
        described_class.search(name: "Hello").load
      }.to perform_sql_query(<<~SQL.squish)
        SELECT "communes".*
        FROM   "communes"
        WHERE  (LOWER(UNACCENT("communes"."name")) LIKE LOWER(UNACCENT('%Hello%')))
      SQL
    end

    it do
      expect{
        described_class.search("Hello").load
      }.to perform_sql_query(<<~SQL.squish)
        SELECT "communes".*
        FROM   "communes"
        LEFT OUTER JOIN "epcis" ON "epcis"."siren" = "communes"."siren_epci"
        LEFT OUTER JOIN "departements" ON "departements"."code_departement" = "communes"."code_departement"
        LEFT OUTER JOIN "regions" ON "regions"."code_region" = "departements"."code_region"
        WHERE (LOWER(UNACCENT("communes"."name")) LIKE LOWER(UNACCENT('%Hello%'))
          OR "communes"."code_insee" = 'Hello'
          OR "communes"."siren_epci" = 'Hello'
          OR "communes"."code_departement" = 'Hello'
          OR LOWER(UNACCENT("epcis"."name")) LIKE LOWER(UNACCENT('%Hello%'))
          OR LOWER(UNACCENT("departements"."name")) LIKE LOWER(UNACCENT('%Hello%'))
          OR LOWER(UNACCENT(\"regions\".\"name\")) LIKE LOWER(UNACCENT('%Hello%')))
      SQL
    end
  end

  # Order scope
  # ----------------------------------------------------------------------------
  describe ".order_by_param" do
    it do
      expect{
        described_class.order_by_param("commune").load
      }.to perform_sql_query(<<~SQL.squish)
        SELECT "communes".*
        FROM   "communes"
        ORDER BY UNACCENT("communes"."name") ASC, "communes"."code_insee" ASC
      SQL
    end

    it do
      expect{
        described_class.order_by_param("departement").load
      }.to perform_sql_query(<<~SQL.squish)
        SELECT "communes".*
        FROM   "communes"
        ORDER BY "communes"."code_departement" ASC, "communes"."code_insee" ASC
      SQL
    end

    it do
      expect{
        described_class.order_by_param("epci").load
      }.to perform_sql_query(<<~SQL.squish)
        SELECT "communes".*
        FROM   "communes"
        LEFT OUTER JOIN "epcis" ON "epcis"."siren" = "communes"."siren_epci"
        ORDER BY UNACCENT("epcis"."name") ASC, "communes"."code_insee" ASC
      SQL
    end

    it do
      expect{
        described_class.order_by_param("-epci").load
      }.to perform_sql_query(<<~SQL.squish)
        SELECT "communes".*
        FROM   "communes"
        LEFT OUTER JOIN "epcis" ON "epcis"."siren" = "communes"."siren_epci"
        ORDER BY UNACCENT("epcis"."name") DESC, "communes"."code_insee" DESC
      SQL
    end
  end

  describe ".order_by_score" do
    it do
      expect{
        described_class.order_by_score("Hello").load
      }.to perform_sql_query(<<~SQL.squish)
        SELECT "communes".*
        FROM   "communes"
        ORDER BY ts_rank_cd(to_tsvector('french', "communes"."name"), to_tsquery('french', 'Hello')) DESC,
                 "communes"."code_insee" ASC
      SQL
    end
  end

  # Other associations
  # ----------------------------------------------------------------------------
  describe "on_territory_collectivities" do
    context "without EPCI attached" do
      let(:commune) { create(:commune) }

      it do
        expect{
          commune.on_territory_collectivities.load
        }.to perform_sql_query(<<~SQL.squish)
          SELECT "collectivities".*
          FROM   "collectivities"
          WHERE "collectivities"."discarded_at" IS NULL
            AND ("collectivities"."territory_type" = 'Commune'
            AND  "collectivities"."territory_id" = '#{commune.id}'
            OR   "collectivities"."territory_type" = 'Departement'
            AND  "collectivities"."territory_id" IN
                   (SELECT "departements"."id"
                    FROM "departements"
                    WHERE "departements"."code_departement" = '#{commune.code_departement}'))
        SQL
      end
    end

    context "with an EPCI attached" do
      let(:commune) { create(:commune, :with_epci) }

      it do
        expect{
          commune.on_territory_collectivities.load
        }.to perform_sql_query(<<~SQL.squish)
          SELECT "collectivities".*
          FROM   "collectivities"
          WHERE "collectivities"."discarded_at" IS NULL
            AND ("collectivities"."territory_type" = 'Commune'
            AND  "collectivities"."territory_id" = '#{commune.id}'
            OR   "collectivities"."territory_type" = 'Departement'
            AND  "collectivities"."territory_id" IN
                   (SELECT "departements"."id"
                    FROM "departements"
                    WHERE "departements"."code_departement" = '#{commune.code_departement}')
            OR   "collectivities"."territory_type" = 'EPCI'
            AND  "collectivities"."territory_id" IN
                   (SELECT "epcis"."id"
                    FROM "epcis"
                    WHERE "epcis"."siren" = '#{commune.siren_epci}'))
        SQL
      end
    end
  end
end
