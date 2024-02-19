# frozen_string_literal: true

require "rails_helper"
require "models/shared_examples"

RSpec.describe EPCI do
  # Associations
  # ----------------------------------------------------------------------------
  describe "associations" do
    it { is_expected.to belong_to(:departement).optional }
    it { is_expected.to have_many(:communes) }
    it { is_expected.to have_one(:region) }
    it { is_expected.to have_one(:registered_collectivity) }
    it { is_expected.to respond_to(:on_territory_collectivities) }
  end

  # Validations
  # ----------------------------------------------------------------------------
  describe "validations" do
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

    it "validates uniqueness of :siren" do
      create(:epci)
      is_expected.to validate_uniqueness_of(:siren).ignoring_case_sensitivity
    end
  end

  # Normalization callbacks
  # ----------------------------------------------------------------------------
  describe "attribute normalization" do
    def build_record(...)
      user = build(:epci, ...)
      user.validate
      user
    end

    describe "#code_departement" do
      it { expect(build_record(code_departement: "")).to  have_attributes(code_departement: nil) }
      it { expect(build_record(code_departement: nil)).to have_attributes(code_departement: nil) }
    end
  end

  # Scopes
  # ----------------------------------------------------------------------------
  describe "scopes" do
    describe ".having_communes" do
      it "searches for EPCIs having communes from the given relation" do
        expect {
          described_class.having_communes(Commune.where(code_departement: "64")).load
        }.to perform_sql_query(<<~SQL)
          SELECT "epcis".*
          FROM   "epcis"
          WHERE  "epcis"."siren" IN (
            SELECT "communes"."siren_epci"
            FROM   "communes"
            WHERE  "communes"."code_departement" = '64'
          )
        SQL
      end
    end

    describe ".search" do
      it "searches for EPCIs with all criteria" do
        expect {
          described_class.search("Hello").load
        }.to perform_sql_query(<<~SQL)
          SELECT "epcis".*
          FROM   "epcis"
          LEFT OUTER JOIN "departements" ON "departements"."code_departement" = "epcis"."code_departement"
          LEFT OUTER JOIN "regions" ON "regions"."code_region" = "departements"."code_region"
          WHERE (
                LOWER(UNACCENT("epcis"."name")) LIKE LOWER(UNACCENT('%Hello%'))
            OR  "epcis"."siren" = 'Hello'
            OR  "epcis"."code_departement" = 'Hello'
            OR  LOWER(UNACCENT("departements"."name")) LIKE LOWER(UNACCENT('%Hello%'))
            OR  LOWER(UNACCENT("regions"."name")) LIKE LOWER(UNACCENT('%Hello%'))
          )
        SQL
      end

      it "searches for EPCIs by matching name" do
        expect {
          described_class.search(name: "Hello").load
        }.to perform_sql_query(<<~SQL)
          SELECT "epcis".*
          FROM   "epcis"
          WHERE  (LOWER(UNACCENT("epcis"."name")) LIKE LOWER(UNACCENT('%Hello%')))
        SQL
      end

      it "searches for EPCIs by matching SIREN" do
        expect {
          described_class.search(siren: "123456789").load
        }.to perform_sql_query(<<~SQL)
          SELECT "epcis".*
          FROM   "epcis"
          WHERE  "epcis"."siren" = '123456789'
        SQL
      end

      it "searches for EPCIs by matching departement code" do
        expect {
          described_class.search(code_departement: "64").load
        }.to perform_sql_query(<<~SQL)
          SELECT "epcis".*
          FROM   "epcis"
          WHERE  "epcis"."code_departement" = '64'
        SQL
      end

      it "searches for EPCIs by matching departement name" do
        expect {
          described_class.search(departement_name: "Pyrén").load
        }.to perform_sql_query(<<~SQL)
          SELECT          "epcis".*
          FROM            "epcis"
          LEFT OUTER JOIN "departements" ON "departements"."code_departement" = "epcis"."code_departement"
          WHERE           (LOWER(UNACCENT("departements"."name")) LIKE LOWER(UNACCENT('%Pyrén%')))
        SQL
      end

      it "searches for EPCIs by matching region name" do
        expect {
          described_class.search(region_name: "Sud").load
        }.to perform_sql_query(<<~SQL)
          SELECT          "epcis".*
          FROM            "epcis"
          LEFT OUTER JOIN "departements" ON "departements"."code_departement" = "epcis"."code_departement"
          LEFT OUTER JOIN "regions" ON "regions"."code_region" = "departements"."code_region"
          WHERE           (LOWER(UNACCENT("regions"."name")) LIKE LOWER(UNACCENT('%Sud%')))
        SQL
      end
    end

    describe ".autocomplete" do
      it "searches for EPCIs with text matching the name or SIREN" do
        expect {
          described_class.autocomplete("Hello").load
        }.to perform_sql_query(<<~SQL)
          SELECT "epcis".*
          FROM   "epcis"
          WHERE (
                LOWER(UNACCENT("epcis"."name")) LIKE LOWER(UNACCENT('%Hello%'))
            OR  "epcis"."siren" = 'Hello'
          )
        SQL
      end
    end
  end

  # Scopes: orders
  # ----------------------------------------------------------------------------
  describe "order scopes" do
    describe ".order_by_param" do
      it "sorts EPCIs by name" do
        expect {
          described_class.order_by_param("name").load
        }.to perform_sql_query(<<~SQL)
          SELECT   "epcis".*
          FROM     "epcis"
          ORDER BY UNACCENT("epcis"."name") ASC NULLS LAST,
                   "epcis"."name" ASC
        SQL
      end

      it "sorts EPCIs by name in reversed order" do
        expect {
          described_class.order_by_param("-name").load
        }.to perform_sql_query(<<~SQL)
          SELECT   "epcis".*
          FROM     "epcis"
          ORDER BY UNACCENT("epcis"."name") DESC NULLS FIRST,
                   "epcis"."name" DESC
        SQL
      end

      it "sorts EPCIs by SIREN" do
        expect {
          described_class.order_by_param("siren").load
        }.to perform_sql_query(<<~SQL)
          SELECT   "epcis".*
          FROM     "epcis"
          ORDER BY "epcis"."siren" ASC,
                   "epcis"."name" ASC
        SQL
      end

      it "sorts EPCIs by SIREN in reversed order" do
        expect {
          described_class.order_by_param("-siren").load
        }.to perform_sql_query(<<~SQL)
          SELECT   "epcis".*
          FROM     "epcis"
          ORDER BY "epcis"."siren" DESC,
                   "epcis"."name" DESC
        SQL
      end

      it "sorts EPCIs by departement" do
        expect {
          described_class.order_by_param("departement").load
        }.to perform_sql_query(<<~SQL)
          SELECT   "epcis".*
          FROM     "epcis"
          ORDER BY "epcis"."code_departement" ASC,
                   "epcis"."name" ASC
        SQL
      end

      it "sorts EPCIs by departement in reversed order" do
        expect {
          described_class.order_by_param("-departement").load
        }.to perform_sql_query(<<~SQL)
          SELECT   "epcis".*
          FROM     "epcis"
          ORDER BY "epcis"."code_departement" DESC,
                   "epcis"."name" DESC
        SQL
      end
    end

    describe ".order_by_score" do
      it "sorts EPCIs by search score" do
        expect {
          described_class.order_by_score("Hello").load
        }.to perform_sql_query(<<~SQL)
          SELECT   "epcis".*
          FROM     "epcis"
          ORDER BY ts_rank_cd(to_tsvector('french', "epcis"."name"), to_tsquery('french', 'Hello')) DESC,
                   "epcis"."name" ASC
        SQL
      end
    end

    describe ".order_by_name" do
      it "sorts EPCIs by name without argument" do
        expect {
          described_class.order_by_name.load
        }.to perform_sql_query(<<~SQL)
          SELECT   "epcis".*
          FROM     "epcis"
          ORDER BY UNACCENT("epcis"."name") ASC NULLS LAST
        SQL
      end

      it "sorts EPCIs by name in ascending order" do
        expect {
          described_class.order_by_name(:asc).load
        }.to perform_sql_query(<<~SQL)
          SELECT   "epcis".*
          FROM     "epcis"
          ORDER BY UNACCENT("epcis"."name") ASC NULLS LAST
        SQL
      end

      it "sorts EPCIs by name in descending order" do
        expect {
          described_class.order_by_name(:desc).load
        }.to perform_sql_query(<<~SQL)
          SELECT   "epcis".*
          FROM     "epcis"
          ORDER BY UNACCENT("epcis"."name") DESC NULLS FIRST
        SQL
      end
    end

    describe ".order_by_siren" do
      it "sorts EPCIs by SIREN without argument" do
        expect {
          described_class.order_by_siren.load
        }.to perform_sql_query(<<~SQL)
          SELECT   "epcis".*
          FROM     "epcis"
          ORDER BY "epcis"."siren" ASC
        SQL
      end

      it "sorts EPCIs by SIREN in ascending order" do
        expect {
          described_class.order_by_siren(:asc).load
        }.to perform_sql_query(<<~SQL)
          SELECT   "epcis".*
          FROM     "epcis"
          ORDER BY "epcis"."siren" ASC
        SQL
      end

      it "sorts EPCIs by SIREN in descending order" do
        expect {
          described_class.order_by_siren(:desc).load
        }.to perform_sql_query(<<~SQL)
          SELECT   "epcis".*
          FROM     "epcis"
          ORDER BY "epcis"."siren" DESC
        SQL
      end
    end

    describe ".order_by_departement" do
      it "sorts EPCIs by departement's code without argument" do
        expect {
          described_class.order_by_departement.load
        }.to perform_sql_query(<<~SQL)
          SELECT   "epcis".*
          FROM     "epcis"
          ORDER BY "epcis"."code_departement" ASC
        SQL
      end

      it "sorts EPCIs by departement's code in ascending order" do
        expect {
          described_class.order_by_departement(:asc).load
        }.to perform_sql_query(<<~SQL)
          SELECT   "epcis".*
          FROM     "epcis"
          ORDER BY "epcis"."code_departement" ASC
        SQL
      end

      it "sorts EPCIs by departement's code in descending order" do
        expect {
          described_class.order_by_departement(:desc).load
        }.to perform_sql_query(<<~SQL)
          SELECT   "epcis".*
          FROM     "epcis"
          ORDER BY "epcis"."code_departement" DESC
        SQL
      end
    end
  end

  # Other associations
  # ----------------------------------------------------------------------------
  describe "other associations" do
    describe "#on_territory_collectivities" do
      subject(:on_territory_collectivities) { epci.on_territory_collectivities }

      let(:epci) { create(:epci) }

      it { expect(on_territory_collectivities).to be_an(ActiveRecord::Relation) }
      it { expect(on_territory_collectivities.model).to eq(Collectivity) }

      it "loads the registered collectivities having this EPCI crossing their territory" do
        expect {
          on_territory_collectivities.load
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
  end

  # Updates methods
  # ----------------------------------------------------------------------------
  describe "update methods" do
    describe ".reset_all_counters" do
      subject(:reset_all_counters) { described_class.reset_all_counters }

      it { expect { reset_all_counters }.to not_raise_error }
      it { expect { reset_all_counters }.to ret(Integer) }
      it { expect { reset_all_counters }.to perform_sql_query("SELECT reset_all_epcis_counters()") }
    end
  end

  # Database constraints and triggers
  # ----------------------------------------------------------------------------
  describe "database constraints" do
    it "asserts the uniqueness of SIREN" do
      existing_epci = create(:epci)
      another_epci  = build(:epci, siren: existing_epci.siren)

      expect { another_epci.save(validate: false) }
        .to raise_error(ActiveRecord::RecordNotUnique).with_message(/PG::UniqueViolation/)
    end

    it "cannot destroy a departement referenced from epcis" do
      departement = create(:departement)
      create(:epci, departement: departement)

      expect { departement.delete }
        .to raise_error(ActiveRecord::InvalidForeignKey).with_message(/PG::ForeignKeyViolation/)
    end
  end

  describe "database triggers" do
    let!(:epcis) { create_list(:epci, 2) }

    describe "about counter caches" do
      describe "#communes_count" do
        let(:commune) { create(:commune, epci: epcis[0]) }

        it "changes on creation" do
          expect { commune }
            .to change { epcis[0].reload.communes_count }.from(0).to(1)
            .and not_change { epcis[1].reload.communes_count }.from(0)
        end

        it "changes on deletion" do
          commune
          expect { commune.destroy }
            .to change { epcis[0].reload.communes_count }.from(1).to(0)
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
            .to change { epcis[0].reload.communes_count }.from(1).to(0)
            .and not_change { epcis[1].reload.communes_count }.from(0)
        end

        it "changes on updating to add the EPCI" do
          commune = create(:commune)

          expect { commune.update(epci: epcis[1]) }
            .to  not_change { epcis[0].reload.communes_count }.from(0)
            .and change { epcis[1].reload.communes_count }.from(0).to(1)
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
  end
end
