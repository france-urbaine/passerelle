# frozen_string_literal: true

require "rails_helper"

RSpec.describe Region do
  # Associations
  # ----------------------------------------------------------------------------
  describe "associations" do
    it { is_expected.to have_many(:departements) }
    it { is_expected.to have_many(:communes) }
    it { is_expected.to have_many(:epcis) }
    it { is_expected.to have_many(:ddfips) }
    it { is_expected.to have_one(:registered_collectivity) }
    it { is_expected.to respond_to(:on_territory_collectivities) }
  end

  # Validations
  # ----------------------------------------------------------------------------
  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:code_region) }

    it { is_expected.to     allow_value("12")  .for(:code_region) }
    it { is_expected.not_to allow_value("12AB").for(:code_region) }

    it "validates uniqueness of :code_region" do
      create(:region)
      is_expected.to validate_uniqueness_of(:code_region).ignoring_case_sensitivity
    end
  end

  # Scopes
  # ----------------------------------------------------------------------------
  describe "scopes" do
    describe ".search" do
      it "searches for regions with text" do
        expect {
          described_class.search("Hello").load
        }.to perform_sql_query(<<~SQL)
          SELECT "regions".*
          FROM   "regions"
          WHERE (LOWER(UNACCENT("regions"."name")) LIKE LOWER(UNACCENT('%Hello%'))
            OR "regions"."code_region" = 'Hello')
        SQL
      end

      it "searches for regions with text matching a single attribute" do
        expect {
          described_class.search(name: "Hello").load
        }.to perform_sql_query(<<~SQL)
          SELECT "regions".*
          FROM   "regions"
          WHERE  (LOWER(UNACCENT("regions"."name")) LIKE LOWER(UNACCENT('%Hello%')))
        SQL
      end
    end

    describe ".order_by_score" do
      it "orders regions by search score" do
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
  end

  # Other associations
  # ----------------------------------------------------------------------------
  describe "other associations" do
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
  end

  # Updates methods
  # ----------------------------------------------------------------------------
  describe "update methods" do
    describe ".reset_all_counters" do
      subject(:reset_all_counters) { described_class.reset_all_counters }

      it { expect { reset_all_counters }.to not_raise_error }
      it { expect { reset_all_counters }.to ret(Integer) }
      it { expect { reset_all_counters }.to perform_sql_query("SELECT reset_all_regions_counters()") }
    end
  end

  # Database constraints and triggers
  # ----------------------------------------------------------------------------
  describe "database triggers" do
    describe "about counter caches" do
      let!(:regions) { create_list(:region, 2) }
      let(:departements) do
        [
          create(:departement, region: regions[0]),
          create(:departement, region: regions[1])
        ]
      end

      describe "#communes_count" do
        let(:commune) { create(:commune, departement: departements[0]) }

        it "changes on creation" do
          expect { commune }
            .to change { regions[0].reload.communes_count }.from(0).to(1)
            .and not_change { regions[1].reload.communes_count }.from(0)
        end

        it "changes on deletion" do
          commune
          expect { commune.destroy }
            .to change { regions[0].reload.communes_count }.from(1).to(0)
            .and not_change { regions[1].reload.communes_count }.from(0)
        end

        it "changes on updating departement" do
          commune
          expect { commune.update(departement: departements[1]) }
            .to  change { departements[0].reload.communes_count }.from(1).to(0)
            .and change { departements[1].reload.communes_count }.from(0).to(1)
        end
      end

      describe "#epcis_count" do
        it do
          expect { create(:epci, departement: departements[0]) }
            .to change { regions[0].reload.epcis_count }.from(0).to(1)
            .and not_change { regions[1].reload.epcis_count }.from(0)
        end

        it do
          expect { create(:commune, :with_epci, departement: departements[0]) }
            .to  not_change { regions[0].reload.epcis_count }.from(0)
            .and not_change { regions[1].reload.epcis_count }.from(0)
        end
      end

      describe "#departements_count" do
        it do
          expect { create(:departement, region: regions[0]) }
            .to change { regions[0].reload.departements_count }.from(0).to(1)
            .and not_change { regions[1].reload.departements_count }.from(0)
        end
      end

      describe "#ddfips_count" do
        it do
          expect { create(:ddfip, departement: departements[0]) }
            .to change { regions[0].reload.ddfips_count }.from(0).to(1)
            .and not_change { regions[1].reload.ddfips_count }.from(0)
        end
      end

      describe "#collectivities_count" do
        it do
          commune = create(:commune, departement: departements[0])
          expect { create(:collectivity, :commune, territory: commune) }
            .to change { regions[0].reload.collectivities_count }.from(0).to(1)
            .and not_change { regions[1].reload.collectivities_count }.from(0)
        end

        it do
          epci = create(:commune, :with_epci, departement: departements[0]).epci
          expect { create(:collectivity, :epci, territory: epci) }
            .to change { regions[0].reload.collectivities_count }.from(0).to(1)
            .and not_change { regions[1].reload.collectivities_count }.from(0)
        end

        it do
          epci = create(:epci, departement: departements[0])
          expect { create(:collectivity, :epci, territory: epci) }
            .to  not_change { regions[0].reload.collectivities_count }.from(0)
            .and not_change { regions[1].reload.collectivities_count }.from(0)
        end

        it do
          expect { create(:collectivity, :departement, territory: departements[0]) }
            .to change { regions[0].reload.collectivities_count }.from(0).to(1)
            .and not_change { regions[1].reload.collectivities_count }.from(0)
        end

        it do
          expect { create(:collectivity, :region, territory: departements[0].region) }
            .to change { regions[0].reload.collectivities_count }.from(0).to(1)
            .and not_change { regions[1].reload.collectivities_count }.from(0)
        end
      end
    end
  end
end
