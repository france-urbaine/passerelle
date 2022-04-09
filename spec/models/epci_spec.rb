# frozen_string_literal: true

require "rails_helper"

RSpec.describe EPCI, type: :model do
  # Associations
  # ----------------------------------------------------------------------------
  it { is_expected.to belong_to(:departement).optional }
  it { is_expected.to have_many(:communes) }
  it { is_expected.to have_many(:collectivities) }
  it { is_expected.to have_one(:region) }

  # Validations
  # ----------------------------------------------------------------------------
  it { is_expected.to     validate_presence_of(:name) }
  it { is_expected.to     validate_presence_of(:siren) }
  it { is_expected.not_to validate_presence_of(:code_departement) }

  it { is_expected.to     allow_value("801453893").for(:siren) }
  it { is_expected.not_to allow_value("1234567AB").for(:siren) }
  it { is_expected.not_to allow_value("1234567891").for(:siren) }

  it { is_expected.to     allow_value("01").for(:code_departement) }
  it { is_expected.to     allow_value("2A").for(:code_departement) }
  it { is_expected.to     allow_value("987").for(:code_departement) }
  it { is_expected.not_to allow_value("1").for(:code_departement) }
  it { is_expected.not_to allow_value("123").for(:code_departement) }
  it { is_expected.not_to allow_value("3C").for(:code_departement) }

  # Search scope
  # ----------------------------------------------------------------------------
  describe ".search" do
    it do
      expect{
        described_class.search(name: "Hello").load
      }.to perform_sql_query(<<~SQL.squish)
        SELECT "epcis".*
        FROM   "epcis"
        WHERE  (LOWER(UNACCENT("epcis"."name")) LIKE LOWER(UNACCENT('%Hello%')))
      SQL
    end

    it do
      expect{
        described_class.search("Hello").load
      }.to perform_sql_query(<<~SQL.squish)
        SELECT "epcis".*
        FROM   "epcis"
        LEFT OUTER JOIN "departements" ON "departements"."code_departement" = "epcis"."code_departement"
        LEFT OUTER JOIN "regions" ON "regions"."code_region" = "departements"."code_region"
        WHERE (LOWER(UNACCENT("epcis"."name")) LIKE LOWER(UNACCENT('%Hello%'))
          OR "epcis"."siren" = 'Hello'
          OR "epcis"."code_departement" = 'Hello'
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
        described_class.order_by_param("epci").load
      }.to perform_sql_query(<<~SQL.squish)
        SELECT "epcis".*
        FROM   "epcis"
        ORDER BY UNACCENT("epcis"."name") ASC, "epcis"."name" ASC
      SQL
    end

    it do
      expect{
        described_class.order_by_param("departement").load
      }.to perform_sql_query(<<~SQL.squish)
        SELECT "epcis".*
        FROM   "epcis"
        ORDER BY "epcis"."code_departement" ASC, "epcis"."name" ASC
      SQL
    end

    it do
      expect{
        described_class.order_by_param("-departement").load
      }.to perform_sql_query(<<~SQL.squish)
        SELECT "epcis".*
        FROM   "epcis"
        ORDER BY "epcis"."code_departement" DESC, "epcis"."name" DESC
      SQL
    end
  end

  describe ".order_by_score" do
    it do
      expect{
        described_class.order_by_score("Hello").load
      }.to perform_sql_query(<<~SQL.squish)
        SELECT "epcis".*
        FROM   "epcis"
        ORDER BY
          ts_rank_cd(to_tsvector('french', "epcis"."name"), to_tsquery('french', 'Hello')) DESC,
          "epcis"."name" ASC
      SQL
    end
  end
end
