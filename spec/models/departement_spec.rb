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

  # Counter caches
  # ----------------------------------------------------------------------------
  describe "counter caches" do
    let!(:departement1) { create(:departement) }
    let!(:departement2) { create(:departement) }

    describe "#communes_count" do
      let(:commune) { create(:commune, departement: departement1) }

      it "changes on creation" do
        expect { commune }
          .to      change { departement1.reload.communes_count }.from(0).to(1)
          .and not_change { departement2.reload.communes_count }.from(0)
      end

      it "changes on deletion" do
        commune
        expect { commune.destroy }
          .to      change { departement1.reload.communes_count }.from(1).to(0)
          .and not_change { departement2.reload.communes_count }.from(0)
      end

      it "changes on updating departement" do
        commune
        expect { commune.update(departement: departement2) }
          .to  change { departement1.reload.communes_count }.from(1).to(0)
          .and change { departement2.reload.communes_count }.from(0).to(1)
      end
    end

    describe "#epcis_count" do
      let(:epci) { create(:epci, departement: departement1) }

      it "changes on creation" do
        expect { epci }
          .to      change { departement1.reload.epcis_count }.from(0).to(1)
          .and not_change { departement2.reload.epcis_count }.from(0)
      end

      it "changes on deletion" do
        epci
        expect { epci.destroy }
          .to      change { departement1.reload.epcis_count }.from(1).to(0)
          .and not_change { departement2.reload.epcis_count }.from(0)
      end

      it "changes on updating departement" do
        epci
        expect { epci.update(departement: departement2) }
          .to  change { departement1.reload.epcis_count }.from(1).to(0)
          .and change { departement2.reload.epcis_count }.from(0).to(1)
      end
    end

    describe "#ddfips_count" do
      let(:ddfip) { create(:ddfip, departement: departement1) }

      it "changes on creation" do
        expect { ddfip }
          .to      change { departement1.reload.ddfips_count }.from(0).to(1)
          .and not_change { departement2.reload.ddfips_count }.from(0)
      end

      it "changes on deletion" do
        ddfip
        expect { ddfip.destroy }
          .to      change { departement1.reload.ddfips_count }.from(1).to(0)
          .and not_change { departement2.reload.ddfips_count }.from(0)
      end

      it "changes on updating departement" do
        ddfip
        expect { ddfip.update(departement: departement2) }
          .to  change { departement1.reload.ddfips_count }.from(1).to(0)
          .and change { departement2.reload.ddfips_count }.from(0).to(1)
      end
    end

    describe "#collectivities_count" do
      shared_examples "trigger changes" do
        let(:collectivity) { create(:collectivity, territory: territory1) }

        it "changes on creation" do
          expect { collectivity }
            .to      change { departement1.reload.collectivities_count }.from(0).to(1)
            .and not_change { departement2.reload.collectivities_count }.from(0)
        end

        it "changes on discarding" do
          collectivity
          expect { collectivity.discard }
            .to      change { departement1.reload.collectivities_count }.from(1).to(0)
            .and not_change { departement2.reload.collectivities_count }.from(0)
        end

        it "changes on undiscarding" do
          collectivity.discard
          expect { collectivity.undiscard }
            .to      change { departement1.reload.collectivities_count }.from(0).to(1)
            .and not_change { departement2.reload.collectivities_count }.from(0)
        end

        it "changes on deletion" do
          collectivity
          expect { collectivity.destroy }
            .to      change { departement1.reload.collectivities_count }.from(1).to(0)
            .and not_change { departement2.reload.collectivities_count }.from(0)
        end

        it "doesn't change when deleting a discarded collectivity" do
          collectivity.discard
          expect { collectivity.destroy }
            .to  not_change { departement1.reload.collectivities_count }.from(0)
            .and not_change { departement2.reload.collectivities_count }.from(0)
        end

        it "changes when updating territory" do
          collectivity
          expect { collectivity.update(territory: territory2) }
            .to  change { departement1.reload.collectivities_count }.from(1).to(0)
            .and change { departement2.reload.collectivities_count }.from(0).to(1)
        end

        it "doesn't change when updating territory of a discarded collectivity" do
          collectivity.discard
          expect { collectivity.update(territory: territory2) }
            .to  not_change { departement1.reload.collectivities_count }.from(0)
            .and not_change { departement2.reload.collectivities_count }.from(0)
        end

        it "changes when combining updating territory and discarding" do
          collectivity
          expect { collectivity.update(territory: territory2, discarded_at: Time.current) }
            .to      change { departement1.reload.collectivities_count }.from(1).to(0)
            .and not_change { departement2.reload.collectivities_count }.from(0)
        end

        it "changes when combining updating territory and undiscarding" do
          collectivity.discard
          expect { collectivity.update(territory: territory2, discarded_at: nil) }
            .to  not_change { departement1.reload.collectivities_count }.from(0)
            .and     change { departement2.reload.collectivities_count }.from(0).to(1)
        end
      end

      context "with a commune" do
        let(:territory1) { create(:commune, departement: departement1) }
        let(:territory2) { create(:commune, departement: departement2) }

        include_examples "trigger changes"
      end

      context "with an EPCI" do
        let(:territory1) { create(:commune, :with_epci, departement: departement1).epci }
        let(:territory2) { create(:commune, :with_epci, departement: departement2).epci }

        include_examples "trigger changes"

        it "doesn't changes when the EPCI has no communes in the departement" do
          territory = create(:epci, departement: departement1)

          expect { create(:collectivity, territory: territory) }
            .not_to change { departement1.reload.collectivities_count }.from(0)
        end
      end

      context "with a departement" do
        let(:territory1) { departement1 }
        let(:territory2) { departement2 }

        include_examples "trigger changes"
      end

      context "with a region" do
        let(:territory1) { departement1.region }
        let(:territory2) { departement2.region }

        include_examples "trigger changes"
      end

      context "with multiple collectivities" do
        it "changes when a commune enter an EPCI" do
          commune = create(:commune, departement: departement1)
          epci    = create(:epci)

          create(:collectivity, territory: commune)
          create(:collectivity, territory: epci)

          expect { commune.update(epci: epci) }
            .to change { departement1.reload.collectivities_count }.from(1).to(2)
        end
      end
    end
  end

  # Reset counters
  # ----------------------------------------------------------------------------
  describe ".reset_all_counters" do
    subject { described_class.reset_all_counters }

    its_block { is_expected.to run_without_error }
    its_block { is_expected.to perform_sql_query("SELECT reset_all_departements_counters()") }
    it        { is_expected.to be_an(Integer) }
  end
end
