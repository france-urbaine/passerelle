# frozen_string_literal: true

require "rails_helper"

RSpec.describe Departement, type: :model do
  # Associations
  # ----------------------------------------------------------------------------
  it { is_expected.to belong_to(:region) }
  it { is_expected.to have_many(:communes) }
  it { is_expected.to have_many(:epcis) }
  it { is_expected.to have_many(:ddfips) }
  it { is_expected.to have_many(:collectivities) }

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
      expect{
        described_class.search(name: "Hello").load
      }.to perform_sql_query(<<~SQL.squish)
        SELECT "departements".*
        FROM   "departements"
        WHERE  (LOWER(UNACCENT("departements"."name")) LIKE LOWER(UNACCENT('%Hello%')))
      SQL
    end

    it do
      expect{
        described_class.search("Hello").load
      }.to perform_sql_query(<<~SQL.squish)
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
      expect{
        described_class.order_by_param("departement").load
      }.to perform_sql_query(<<~SQL.squish)
        SELECT "departements".*
        FROM   "departements"
        ORDER BY "departements"."code_departement" ASC
      SQL
    end

    it do
      expect{
        described_class.order_by_param("-departement").load
      }.to perform_sql_query(<<~SQL.squish)
        SELECT "departements".*
        FROM   "departements"
        ORDER BY "departements"."code_departement" DESC
      SQL
    end
  end
end
