# frozen_string_literal: true

require "rails_helper"

RSpec.describe Commune, type: :model do
  # Associations
  # ----------------------------------------------------------------------------
  it { is_expected.to belong_to(:departement).required }
  it { is_expected.to belong_to(:epci).optional }
  it { is_expected.to have_many(:collectivities) }

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

  # Search
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
end
