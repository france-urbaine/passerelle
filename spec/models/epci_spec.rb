# frozen_string_literal: true

require "rails_helper"
require "models/shared_examples"

RSpec.describe EPCI do
  # Associations
  # ----------------------------------------------------------------------------
  it { is_expected.to belong_to(:departement).optional }
  it { is_expected.to have_many(:communes) }
  it { is_expected.to have_one(:region) }
  it { is_expected.to have_one(:registered_collectivity) }
  it { is_expected.to respond_to(:on_territory_collectivities) }

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
      expect {
        described_class.search(name: "Hello").load
      }.to perform_sql_query(<<~SQL)
        SELECT "epcis".*
        FROM   "epcis"
        WHERE  (LOWER(UNACCENT("epcis"."name")) LIKE LOWER(UNACCENT('%Hello%')))
      SQL
    end

    it do
      expect {
        described_class.search("Hello").load
      }.to perform_sql_query(<<~SQL)
        SELECT "epcis".*
        FROM   "epcis"
        LEFT OUTER JOIN "departements" ON "departements"."code_departement" = "epcis"."code_departement"
        LEFT OUTER JOIN "regions" ON "regions"."code_region" = "departements"."code_region"
        WHERE (LOWER(UNACCENT("epcis"."name")) LIKE LOWER(UNACCENT('%Hello%'))
          OR "epcis"."siren" = 'Hello'
          OR "epcis"."code_departement" = 'Hello'
          OR LOWER(UNACCENT("departements"."name")) LIKE LOWER(UNACCENT('%Hello%'))
          OR LOWER(UNACCENT("regions"."name")) LIKE LOWER(UNACCENT('%Hello%')))
      SQL
    end
  end

  # Order scope
  # ----------------------------------------------------------------------------
  describe ".order_by_param" do
    it do
      expect {
        described_class.order_by_param("epci").load
      }.to perform_sql_query(<<~SQL)
        SELECT "epcis".*
        FROM   "epcis"
        ORDER BY UNACCENT("epcis"."name") ASC, "epcis"."name" ASC
      SQL
    end

    it do
      expect {
        described_class.order_by_param("departement").load
      }.to perform_sql_query(<<~SQL)
        SELECT "epcis".*
        FROM   "epcis"
        ORDER BY "epcis"."code_departement" ASC, "epcis"."name" ASC
      SQL
    end

    it do
      expect {
        described_class.order_by_param("-departement").load
      }.to perform_sql_query(<<~SQL)
        SELECT "epcis".*
        FROM   "epcis"
        ORDER BY "epcis"."code_departement" DESC, "epcis"."name" DESC
      SQL
    end
  end

  describe ".order_by_score" do
    it do
      expect {
        described_class.order_by_score("Hello").load
      }.to perform_sql_query(<<~SQL)
        SELECT "epcis".*
        FROM   "epcis"
        ORDER BY ts_rank_cd(to_tsvector('french', "epcis"."name"), to_tsquery('french', 'Hello')) DESC,
                 "epcis"."name" ASC
      SQL
    end
  end

  # Other associations
  # ----------------------------------------------------------------------------
  describe "#on_territory_collectivities" do
    let(:epci) { create(:epci) }

    it do
      expect {
        epci.on_territory_collectivities.load
      }.to perform_sql_query(<<~SQL)
        SELECT "collectivities".*
        FROM   "collectivities"
        WHERE  "collectivities"."discarded_at" IS NULL
          AND (
                "collectivities"."territory_type" = 'EPCI'
            AND "collectivities"."territory_id"   = '#{epci.id}'
            OR  "collectivities"."territory_type" = 'Commune'
            AND "collectivities"."territory_id" IN (
                  SELECT "communes"."id"
                  FROM "communes"
                  WHERE "communes"."siren_epci" = '#{epci.siren}'
            )
            OR  "collectivities"."territory_type" = 'Departement'
            AND "collectivities"."territory_id" IN (
                  SELECT "departements"."id"
                  FROM "departements"
                  INNER JOIN "communes" ON "communes"."code_departement" = "departements"."code_departement"
                  WHERE "communes"."siren_epci" = '#{epci.siren}'
            )
          )
      SQL
    end
  end

  # Counter caches
  # ----------------------------------------------------------------------------
  describe "counter caches" do
    let!(:epcis) { create_list(:epci, 2) }

    describe "#communes_count" do
      let(:commune) { create(:commune, epci: epcis[0]) }

      it "changes on creation" do
        expect { commune }
          .to      change { epcis[0].reload.communes_count }.from(0).to(1)
          .and not_change { epcis[1].reload.communes_count }.from(0)
      end

      it "changes on deletion" do
        commune
        expect { commune.destroy }
          .to      change { epcis[0].reload.communes_count }.from(1).to(0)
          .and not_change { epcis[1].reload.communes_count }.from(0)
      end

      it "changes on updating EPCI" do
        commune
        expect { commune.update(epci: epcis[1]) }
          .to  change { epcis[0].reload.communes_count }.from(1).to(0)
          .and change { epcis[1].reload.communes_count }.from(0).to(1)
      end

      it "changes on updating to remove the EPCI" do
        commune
        expect { commune.update(epci: nil) }
          .to      change { epcis[0].reload.communes_count }.from(1).to(0)
          .and not_change { epcis[1].reload.communes_count }.from(0)
      end

      it "changes on updating to add the EPCI" do
        commune = create(:commune)

        expect { commune.update(epci: epcis[1]) }
          .to  not_change { epcis[0].reload.communes_count }.from(0)
          .and     change { epcis[1].reload.communes_count }.from(0).to(1)
      end
    end

    describe "#collectivities_count" do
      let!(:communes) do
        [
          create(:commune, epci: epcis[0]),
          create(:commune, epci: epcis[1])
        ]
      end

      context "with communes" do
        it_behaves_like "it changes collectivities count" do
          let(:subjects)    { epcis }
          let(:territories) { communes }
        end
      end

      context "with EPCIs" do
        it_behaves_like "it changes collectivities count" do
          let(:subjects)    { epcis }
          let(:territories) { epcis }
        end
      end

      context "with departements" do
        it_behaves_like "it changes collectivities count" do
          let(:subjects)    { epcis }
          let(:territories) { communes.map(&:departement) }
        end
      end

      context "with regions" do
        it_behaves_like "it changes collectivities count" do
          let(:subjects)    { epcis }
          let(:territories) { communes.map(&:region) }
        end
      end
    end
  end

  # Reset counters
  # ----------------------------------------------------------------------------
  describe ".reset_all_counters" do
    subject(:reset_all_counters) { described_class.reset_all_counters }

    it { expect { reset_all_counters }.to run_without_error }
    it { expect { reset_all_counters }.to ret(Integer) }
    it { expect { reset_all_counters }.to perform_sql_query("SELECT reset_all_epcis_counters()") }
  end
end
