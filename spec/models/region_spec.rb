# frozen_string_literal: true

require "rails_helper"

RSpec.describe Region do
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

  # Counter caches
  # ----------------------------------------------------------------------------
  describe "counter caches" do
    let!(:region1)     { create(:region) }
    let!(:region2)     { create(:region) }
    let(:departement1) { create(:departement, region: region1) }
    let(:departement2) { create(:departement, region: region2) }

    describe "#communes_count" do
      let(:commune) { create(:commune, departement: departement1) }

      it "changes on creation" do
        expect { commune }
          .to      change { region1.reload.communes_count }.from(0).to(1)
          .and not_change { region2.reload.communes_count }.from(0)
      end

      it "changes on deletion" do
        commune
        expect { commune.destroy }
          .to      change { region1.reload.communes_count }.from(1).to(0)
          .and not_change { region2.reload.communes_count }.from(0)
      end

      it "changes on updating departement" do
        commune
        expect { commune.update(departement: departement2) }
          .to  change { departement1.reload.communes_count }.from(1).to(0)
          .and change { departement2.reload.communes_count }.from(0).to(1)
      end
    end

    describe ".communes_count" do
      it do
        expect { create(:commune, departement: departement1) }
          .to      change { region1.reload.communes_count }.from(0).to(1)
          .and not_change { region2.reload.communes_count }.from(0)
      end
    end

    describe ".epcis_count" do
      it do
        expect { create(:epci, departement: departement1) }
          .to      change { region1.reload.epcis_count }.from(0).to(1)
          .and not_change { region2.reload.epcis_count }.from(0)
      end

      it do
        expect { create(:commune, :with_epci, departement: departement1) }
          .to  not_change { region1.reload.epcis_count }.from(0)
          .and not_change { region2.reload.epcis_count }.from(0)
      end
    end

    describe ".departements_count" do
      it do
        expect { departement1 }
          .to      change { region1.reload.departements_count }.from(0).to(1)
          .and not_change { region2.reload.departements_count }.from(0)
      end
    end

    describe ".ddfips_count" do
      it do
        expect { create(:ddfip, departement: departement1) }
          .to      change { region1.reload.ddfips_count }.from(0).to(1)
          .and not_change { region2.reload.ddfips_count }.from(0)
      end
    end

    describe ".collectivities_count" do
      it do
        commune = create(:commune, departement: departement1)
        expect { create(:collectivity, :commune, territory: commune) }
          .to      change { region1.reload.collectivities_count }.from(0).to(1)
          .and not_change { region2.reload.collectivities_count }.from(0)
      end

      it do
        epci = create(:commune, :with_epci, departement: departement1).epci
        expect { create(:collectivity, :epci, territory: epci) }
          .to      change { region1.reload.collectivities_count }.from(0).to(1)
          .and not_change { region2.reload.collectivities_count }.from(0)
      end

      it do
        epci = create(:epci, departement: departement1)
        expect { create(:collectivity, :epci, territory: epci) }
          .to  not_change { region1.reload.collectivities_count }.from(0)
          .and not_change { region2.reload.collectivities_count }.from(0)
      end

      it do
        expect { create(:collectivity, :departement, territory: departement1) }
          .to      change { region1.reload.collectivities_count }.from(0).to(1)
          .and not_change { region2.reload.collectivities_count }.from(0)
      end

      it do
        expect { create(:collectivity, :region, territory: departement1.region) }
          .to      change { region1.reload.collectivities_count }.from(0).to(1)
          .and not_change { region2.reload.collectivities_count }.from(0)
      end
    end
  end

  # Reset counters
  # ----------------------------------------------------------------------------
  describe ".reset_all_counters" do
    subject { described_class.reset_all_counters }

    its_block { is_expected.to run_without_error }
    its_block { is_expected.to ret(Integer) }
    its_block { is_expected.to perform_sql_query("SELECT reset_all_regions_counters()") }
  end
end
