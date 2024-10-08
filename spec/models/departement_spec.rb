# frozen_string_literal: true

require "rails_helper"
require "models/shared_examples"

RSpec.describe Departement do
  # Associations
  # ----------------------------------------------------------------------------
  describe "associations" do
    it { is_expected.to belong_to(:region).required }
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

    it "validates uniqueness of :code_departement" do
      create(:departement)
      is_expected.to validate_uniqueness_of(:code_departement).ignoring_case_sensitivity
    end
  end

  # Normalization callbacks
  # ----------------------------------------------------------------------------
  describe "attribute normalization" do
    # Create only one region to reduce the number of queries and records to create
    let_it_be(:region) { create(:region) }

    def create_record(**)
      create(:departement, region:, **)
    end

    describe "#qualified_name" do
      it { expect(create_record(name: "Guyanne")).to         have_attributes(qualified_name: "Département de Guyanne") }
      it { expect(create_record(name: "Hautes-Pyrénées")).to have_attributes(qualified_name: "Département de Hautes-Pyrénées") }
    end
  end

  # Scopes: searches
  # ----------------------------------------------------------------------------
  describe "search scopes" do
    describe ".search" do
      it "searches for departements with all criteria" do
        expect {
          described_class.search("Hello").load
        }.to perform_sql_query(<<~SQL)
          SELECT "departements".*
          FROM   "departements"
          LEFT OUTER JOIN "regions" ON "regions"."code_region" = "departements"."code_region"
          WHERE (     (LOWER(UNACCENT("departements"."name")) LIKE LOWER(UNACCENT('%Hello%')))
                  OR  "departements"."code_departement" = 'Hello'
                  OR  (LOWER(UNACCENT("regions"."name")) LIKE LOWER(UNACCENT('%Hello%')))
                )
        SQL
      end

      it "searches for departements by matching name" do
        expect {
          described_class.search(name: "Hello").load
        }.to perform_sql_query(<<~SQL)
          SELECT "departements".*
          FROM   "departements"
          WHERE  (LOWER(UNACCENT("departements"."name")) LIKE LOWER(UNACCENT('%Hello%')))
        SQL
      end

      it "searches for departements by matching departement code" do
        expect {
          described_class.search(code_departement: "64").load
        }.to perform_sql_query(<<~SQL)
          SELECT "departements".*
          FROM   "departements"
          WHERE  "departements"."code_departement" = '64'
        SQL
      end

      it "searches for departements by matching region name" do
        expect {
          described_class.search(region_name: "Sud").load
        }.to perform_sql_query(<<~SQL)
          SELECT          "departements".*
          FROM            "departements"
          LEFT OUTER JOIN "regions" ON "regions"."code_region" = "departements"."code_region"
          WHERE           (LOWER(UNACCENT("regions"."name")) LIKE LOWER(UNACCENT('%Sud%')))
        SQL
      end
    end

    describe ".autocomplete" do
      it "searches for departements with text matching the qualified name or its code" do
        expect {
          described_class.autocomplete("Hello").load
        }.to perform_sql_query(<<~SQL)
          SELECT "departements".*
          FROM   "departements"
          WHERE (     (LOWER(UNACCENT("departements"."qualified_name")) LIKE LOWER(UNACCENT('%Hello%')))
                  OR  "departements"."code_departement" = 'Hello'
                )
        SQL
      end
    end
  end

  # Scopes: orders
  # ----------------------------------------------------------------------------
  describe "order scopes" do
    describe ".order_by_param" do
      it "sorts departements by name" do
        expect {
          described_class.order_by_param("name").load
        }.to perform_sql_query(<<~SQL)
          SELECT   "departements".*
          FROM     "departements"
          ORDER BY UNACCENT("departements"."name") ASC NULLS LAST,
                   "departements"."code_departement" ASC
        SQL
      end

      it "sorts departements by name in reversed order" do
        expect {
          described_class.order_by_param("-name").load
        }.to perform_sql_query(<<~SQL)
          SELECT   "departements".*
          FROM     "departements"
          ORDER BY UNACCENT("departements"."name") DESC NULLS FIRST,
                   "departements"."code_departement" DESC
        SQL
      end

      it "sorts departements by code" do
        expect {
          described_class.order_by_param("code").load
        }.to perform_sql_query(<<~SQL)
          SELECT   "departements".*
          FROM     "departements"
          ORDER BY "departements"."code_departement" ASC
        SQL
      end

      it "sorts departements by code in reversed order" do
        expect {
          described_class.order_by_param("-code").load
        }.to perform_sql_query(<<~SQL)
          SELECT   "departements".*
          FROM     "departements"
          ORDER BY "departements"."code_departement" DESC
        SQL
      end

      it "sorts departements by region" do
        expect {
          described_class.order_by_param("region").load
        }.to perform_sql_query(<<~SQL)
          SELECT   "departements".*
          FROM     "departements"
          ORDER BY "departements"."code_region" ASC, "departements"."code_departement" ASC
        SQL
      end

      it "sorts departements by region in reversed order" do
        expect {
          described_class.order_by_param("-region").load
        }.to perform_sql_query(<<~SQL)
          SELECT   "departements".*
          FROM     "departements"
          ORDER BY "departements"."code_region" DESC, "departements"."code_departement" DESC
        SQL
      end
    end

    describe ".order_by_score" do
      it "sorts departements by search score" do
        expect {
          described_class.order_by_score("Hello").load
        }.to perform_sql_query(<<~SQL)
          SELECT   "departements".*
          FROM     "departements"
          ORDER BY ts_rank_cd(to_tsvector('french', "departements"."name"), to_tsquery('french', 'Hello')) DESC,
                   "departements"."code_departement" ASC
        SQL
      end
    end

    describe ".order_by_name" do
      it "sorts departements by name without argument" do
        expect {
          described_class.order_by_name.load
        }.to perform_sql_query(<<~SQL)
          SELECT   "departements".*
          FROM     "departements"
          ORDER BY UNACCENT("departements"."name") ASC NULLS LAST
        SQL
      end

      it "sorts departements by name in ascending order" do
        expect {
          described_class.order_by_name(:asc).load
        }.to perform_sql_query(<<~SQL)
          SELECT   "departements".*
          FROM     "departements"
          ORDER BY UNACCENT("departements"."name") ASC NULLS LAST
        SQL
      end

      it "sorts departements by name in descending order" do
        expect {
          described_class.order_by_name(:desc).load
        }.to perform_sql_query(<<~SQL)
          SELECT   "departements".*
          FROM     "departements"
          ORDER BY UNACCENT("departements"."name") DESC NULLS FIRST
        SQL
      end
    end

    describe ".order_by_code" do
      it "sorts departements by code without argument" do
        expect {
          described_class.order_by_code.load
        }.to perform_sql_query(<<~SQL)
          SELECT   "departements".*
          FROM     "departements"
          ORDER BY "departements"."code_departement" ASC
        SQL
      end

      it "sorts departements by code in ascending order" do
        expect {
          described_class.order_by_code(:asc).load
        }.to perform_sql_query(<<~SQL)
          SELECT   "departements".*
          FROM     "departements"
          ORDER BY "departements"."code_departement" ASC
        SQL
      end

      it "sorts departements by code in descending order" do
        expect {
          described_class.order_by_code(:desc).load
        }.to perform_sql_query(<<~SQL)
          SELECT   "departements".*
          FROM     "departements"
          ORDER BY "departements"."code_departement" DESC
        SQL
      end
    end

    describe ".order_by_region" do
      it "sorts departements by region's code without argument" do
        expect {
          described_class.order_by_region.load
        }.to perform_sql_query(<<~SQL)
          SELECT   "departements".*
          FROM     "departements"
          ORDER BY "departements"."code_region" ASC
        SQL
      end

      it "sorts departements by region's code in ascending order" do
        expect {
          described_class.order_by_region(:asc).load
        }.to perform_sql_query(<<~SQL)
          SELECT   "departements".*
          FROM     "departements"
          ORDER BY "departements"."code_region" ASC
        SQL
      end

      it "sorts departements by region's code in descending order" do
        expect {
          described_class.order_by_region(:desc).load
        }.to perform_sql_query(<<~SQL)
          SELECT   "departements".*
          FROM     "departements"
          ORDER BY "departements"."code_region" DESC
        SQL
      end
    end
  end

  # Other associations
  # ----------------------------------------------------------------------------
  describe "other associations" do
    describe "#on_territory_collectivities" do
      subject(:on_territory_collectivities) { departement.on_territory_collectivities }

      let(:departement) { create(:departement) }

      it { expect(on_territory_collectivities).to be_an(ActiveRecord::Relation) }
      it { expect(on_territory_collectivities.model).to eq(Collectivity) }

      it "loads the registered collectivities having this departement crossing their territory" do
        expect {
          on_territory_collectivities.load
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
  end

  # Updates methods
  # ----------------------------------------------------------------------------
  describe "update methods" do
    describe ".reset_all_counters" do
      subject(:reset_all_counters) { described_class.reset_all_counters }

      before { create_list(:departement, 2) }

      it { expect { reset_all_counters }.to perform_sql_query("SELECT reset_all_departements_counters()") }

      it "returns the count of departements" do
        expect(reset_all_counters).to eq(2)
      end
    end
  end

  # Database constraints and triggers
  # ----------------------------------------------------------------------------
  describe "database constraints" do
    it "asserts the uniqueness of code_departement" do
      existing_departement = create(:departement)
      another_departement  = build(:departement, code_departement: existing_departement.code_departement)

      expect { another_departement.save(validate: false) }
        .to raise_error(ActiveRecord::RecordNotUnique).with_message(/PG::UniqueViolation/)
    end

    it "cannot destroy a region referenced from departements" do
      region = create(:region)
      create(:departement, region: region)

      expect { region.delete }
        .to raise_error(ActiveRecord::InvalidForeignKey).with_message(/PG::ForeignKeyViolation/)
    end
  end

  describe "database triggers" do
    let!(:departements) { create_list(:departement, 2) }

    describe "about counter caches" do
      describe "#communes_count" do
        let(:commune) { create(:commune, departement: departements[0]) }

        it "changes on creation" do
          expect { commune }
            .to change { departements[0].reload.communes_count }.from(0).to(1)
            .and not_change { departements[1].reload.communes_count }.from(0)
        end

        it "changes on deletion" do
          commune
          expect { commune.destroy }
            .to change { departements[0].reload.communes_count }.from(1).to(0)
            .and not_change { departements[1].reload.communes_count }.from(0)
        end

        it "changes on updating departement" do
          commune
          expect { commune.update(departement: departements[1]) }
            .to  change { departements[0].reload.communes_count }.from(1).to(0)
            .and change { departements[1].reload.communes_count }.from(0).to(1)
        end
      end

      describe "#epcis_count" do
        let(:epci) { create(:epci, departement: departements[0]) }

        it "changes on creation" do
          expect { epci }
            .to change { departements[0].reload.epcis_count }.from(0).to(1)
            .and not_change { departements[1].reload.epcis_count }.from(0)
        end

        it "changes on deletion" do
          epci
          expect { epci.destroy }
            .to change { departements[0].reload.epcis_count }.from(1).to(0)
            .and not_change { departements[1].reload.epcis_count }.from(0)
        end

        it "changes on updating departement" do
          epci
          expect { epci.update(departement: departements[1]) }
            .to  change { departements[0].reload.epcis_count }.from(1).to(0)
            .and change { departements[1].reload.epcis_count }.from(0).to(1)
        end
      end

      describe "#ddfips_count" do
        let(:ddfip) { create(:ddfip, departement: departements[0]) }

        it "changes on creation" do
          expect { ddfip }
            .to change { departements[0].reload.ddfips_count }.from(0).to(1)
            .and not_change { departements[1].reload.ddfips_count }.from(0)
        end

        it "changes on deletion" do
          ddfip
          expect { ddfip.destroy }
            .to change { departements[0].reload.ddfips_count }.from(1).to(0)
            .and not_change { departements[1].reload.ddfips_count }.from(0)
        end

        it "changes on updating departement" do
          ddfip
          expect { ddfip.update(departement: departements[1]) }
            .to  change { departements[0].reload.ddfips_count }.from(1).to(0)
            .and change { departements[1].reload.ddfips_count }.from(0).to(1)
        end
      end

      describe "#collectivities_count" do
        context "with communes" do
          it_behaves_like "it changes collectivities count" do
            let(:subjects)    { departements }
            let(:territories) do
              [
                create(:commune, departement: departements[0]),
                create(:commune, departement: departements[1])
              ]
            end
          end
        end

        context "with EPCIs" do
          it_behaves_like "it changes collectivities count" do
            let(:subjects)    { departements }
            let(:territories) { create_list(:epci, 2) }

            before do
              create(:commune, departement: departements[0], epci: territories[0])
              create(:commune, departement: departements[1], epci: territories[1])
            end

            it "doesn't changes when the EPCI has there are no communes in the departement" do
              territory = create(:epci, departement: departements[0])

              expect { create(:collectivity, territory: territory) }
                .not_to change { departements[0].reload.collectivities_count }.from(0)
            end
          end
        end

        context "with departements" do
          it_behaves_like "it changes collectivities count" do
            let(:subjects)    { departements }
            let(:territories) { departements }
          end
        end

        context "with regions" do
          it_behaves_like "it changes collectivities count" do
            let(:subjects)    { departements }
            let(:territories) { departements.map(&:region) }
          end
        end

        context "with multiple collectivities" do
          it "changes when a commune enter an EPCI" do
            commune = create(:commune, departement: departements[0])
            epci    = create(:epci)

            create(:collectivity, territory: commune)
            create(:collectivity, territory: epci)

            expect { commune.update(epci: epci) }
              .to change { departements[0].reload.collectivities_count }.from(1).to(2)
          end
        end
      end
    end
  end
end
