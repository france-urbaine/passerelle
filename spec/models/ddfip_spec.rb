# frozen_string_literal: true

require "rails_helper"

RSpec.describe DDFIP, type: :model do
  # Associations
  # ----------------------------------------------------------------------------
  it { is_expected.to belong_to(:departement).required }
  it { is_expected.to have_many(:epcis) }
  it { is_expected.to have_many(:communes) }
  it { is_expected.to have_one(:region) }
  it { is_expected.to have_many(:users) }

  # Validations
  # ----------------------------------------------------------------------------
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:code_departement) }

  it { is_expected.to     allow_value("01").for(:code_departement) }
  it { is_expected.to     allow_value("2A").for(:code_departement) }
  it { is_expected.to     allow_value("987").for(:code_departement) }
  it { is_expected.not_to allow_value("1").for(:code_departement) }
  it { is_expected.not_to allow_value("123").for(:code_departement) }
  it { is_expected.not_to allow_value("3C").for(:code_departement) }

  context "with an existing DDFIP" do
    # FYI: About uniqueness validations, case insensitivity and accents:
    # You should read ./docs/uniqueness_validations_and_accents.md
    before { create(:ddfip) }

    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
  end

  context "when existing collectivity is discarded" do
    before { create(:ddfip, :discarded) }

    it { is_expected.not_to validate_uniqueness_of(:name).case_insensitive }
  end

  # Search
  # ----------------------------------------------------------------------------
  describe ".search" do
    it do
      expect {
        described_class.search("Hello").load
      }.to perform_sql_query(<<~SQL.squish)
        SELECT "ddfips".*
        FROM   "ddfips"
        WHERE (LOWER(UNACCENT("ddfips"."name")) LIKE LOWER(UNACCENT('%Hello%'))
          OR "ddfips"."code_departement" = 'Hello')
      SQL
    end
  end

  # Other associations
  # ----------------------------------------------------------------------------
  describe "#on_territory_collectivities" do
    let(:ddfip) { create(:ddfip) }

    it do
      expect {
        ddfip.on_territory_collectivities.load
      }.to perform_sql_query(<<~SQL)
        SELECT "collectivities".*
        FROM   "collectivities"
        WHERE  "collectivities"."discarded_at" IS NULL
          AND (
                "collectivities"."territory_type" = 'Commune'
            AND "collectivities"."territory_id" IN (
                  SELECT "communes"."id"
                  FROM "communes"
                  WHERE "communes"."code_departement" = '#{ddfip.code_departement}'
            )
            OR  "collectivities"."territory_type" = 'EPCI'
            AND "collectivities"."territory_id" IN (
                  SELECT "epcis"."id"
                  FROM "epcis"
                  INNER JOIN "communes" ON "communes"."siren_epci" = "epcis"."siren"
                  WHERE "communes"."code_departement" = '#{ddfip.code_departement}'
            )
            OR  "collectivities"."territory_type" = 'Departement'
            AND "collectivities"."territory_id" IN (
              SELECT "departements"."id"
              FROM "departements"
              WHERE "departements"."code_departement" = '#{ddfip.code_departement}'
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
        UPDATE "ddfips"
        SET "users_count" = (
              SELECT COUNT(*)
              FROM   "users"
              WHERE  (
                    "users"."organization_type" = 'DDFIP'
                AND "users"."organization_id" = "ddfips"."id"
              )
            ),
            "collectivities_count" = (
              SELECT COUNT(*)
              FROM   "collectivities"
              WHERE  "collectivities"."discarded_at" IS NULL
                AND (
                      "collectivities"."territory_type" = 'Commune'
                  AND "collectivities"."territory_id" IN (
                        SELECT "communes"."id"
                        FROM "communes"
                        WHERE ("communes"."code_departement" = "ddfips"."code_departement")
                  )
                  OR  "collectivities"."territory_type" = 'EPCI'
                  AND "collectivities"."territory_id" IN (
                        SELECT "epcis"."id"
                        FROM "epcis"
                        INNER JOIN "communes" ON "communes"."siren_epci" = "epcis"."siren"
                        WHERE ("communes"."code_departement" = "ddfips"."code_departement")
                  )
                  OR  "collectivities"."territory_type" = 'Departement'
                  AND "collectivities"."territory_id" IN (
                    SELECT "departements"."id"
                    FROM "departements"
                    WHERE ("departements"."code_departement" = "ddfips"."code_departement")
                  )
                )
            )
      SQL
    end
  end
end
