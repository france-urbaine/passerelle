# frozen_string_literal: true

require "rails_helper"
require "models/shared_examples"

RSpec.describe DDFIP do
  # Associations
  # ----------------------------------------------------------------------------
  describe "associations" do
    it { is_expected.to belong_to(:departement).required }
    it { is_expected.to have_many(:epcis) }
    it { is_expected.to have_many(:communes) }
    it { is_expected.to have_one(:region).through(:departement) }
    it { is_expected.to have_many(:users) }
    it { is_expected.to have_many(:offices) }
    it { is_expected.to have_many(:workshops) }
  end

  # Validations
  # ----------------------------------------------------------------------------
  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:code_departement) }

    it { is_expected.to     allow_value("01").for(:code_departement) }
    it { is_expected.to     allow_value("2A").for(:code_departement) }
    it { is_expected.to     allow_value("987").for(:code_departement) }
    it { is_expected.not_to allow_value("1").for(:code_departement) }
    it { is_expected.not_to allow_value("123").for(:code_departement) }
    it { is_expected.not_to allow_value("3C").for(:code_departement) }

    it "validates uniqueness of :name" do
      create(:ddfip)
      is_expected.to validate_uniqueness_of(:name).ignoring_case_sensitivity
    end

    it "ignores discarded records when validating uniqueness of :name" do
      create(:ddfip, :discarded)
      is_expected.not_to validate_uniqueness_of(:name).ignoring_case_sensitivity
    end

    it "raises an exception when undiscarding a record when its attributes is already used by other records" do
      discarded_ddfip = create(:ddfip, :discarded)
      create(:ddfip, name: discarded_ddfip.name)

      expect { discarded_ddfip.undiscard }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  # Scopes
  # ----------------------------------------------------------------------------
  describe "scopes" do
    describe ".search" do
      it "searches for DDFIPs with all criteria" do
        expect {
          described_class.search("Hello").load
        }.to perform_sql_query(<<~SQL.squish)
          SELECT          "ddfips".*
          FROM            "ddfips"
          LEFT OUTER JOIN "departements" ON "departements"."code_departement" = "ddfips"."code_departement"
          LEFT OUTER JOIN "regions" ON "regions"."code_region" = "departements"."code_region"
          WHERE (
                LOWER(UNACCENT("ddfips"."name")) LIKE LOWER(UNACCENT('%Hello%'))
            OR  "ddfips"."code_departement" = 'Hello'
            OR  LOWER(UNACCENT("departements"."name")) LIKE LOWER(UNACCENT('%Hello%'))
            OR  LOWER(UNACCENT("regions"."name"))      LIKE LOWER(UNACCENT('%Hello%'))
          )
        SQL
      end

      it "searches for DDFIPs by matching name" do
        expect {
          described_class.search(name: "Hello").load
        }.to perform_sql_query(<<~SQL.squish)
          SELECT "ddfips".*
          FROM   "ddfips"
          WHERE  (LOWER(UNACCENT("ddfips"."name")) LIKE LOWER(UNACCENT('%Hello%')))
        SQL
      end

      it "searches for DDFIPs by matching departement code" do
        expect {
          described_class.search(code_departement: "64").load
        }.to perform_sql_query(<<~SQL)
          SELECT "ddfips".*
          FROM   "ddfips"
          WHERE  "ddfips"."code_departement" = '64'
        SQL
      end

      it "searches for DDFIPs by matching departement name" do
        expect {
          described_class.search(departement_name: "Pyrén").load
        }.to perform_sql_query(<<~SQL)
          SELECT          "ddfips".*
          FROM            "ddfips"
          LEFT OUTER JOIN "departements" ON "departements"."code_departement" = "ddfips"."code_departement"
          WHERE            (LOWER(UNACCENT("departements"."name")) LIKE LOWER(UNACCENT('%Pyrén%')))
        SQL
      end

      it "searches for DDFIPs by matching region name" do
        expect {
          described_class.search(region_name: "Sud").load
        }.to perform_sql_query(<<~SQL)
          SELECT          "ddfips".*
          FROM            "ddfips"
          LEFT OUTER JOIN "departements" ON "departements"."code_departement" = "ddfips"."code_departement"
          LEFT OUTER JOIN "regions" ON "regions"."code_region" = "departements"."code_region"
          WHERE           (LOWER(UNACCENT("regions"."name")) LIKE LOWER(UNACCENT('%Sud%')))
        SQL
      end
    end

    describe ".autocomplete" do
      it "searches for DDFIPs with text matching the name" do
        expect {
          described_class.autocomplete("Hello").load
        }.to perform_sql_query(<<~SQL)
          SELECT "ddfips".*
          FROM   "ddfips"
          WHERE (
                LOWER(UNACCENT("ddfips"."name")) LIKE LOWER(UNACCENT('%Hello%'))
            OR  "ddfips"."code_departement" = 'Hello'
          )
        SQL
      end
    end

    describe ".order_by_param" do
      it "orders DDFIPs by name" do
        expect {
          described_class.order_by_param("name").load
        }.to perform_sql_query(<<~SQL)
          SELECT   "ddfips".*
          FROM     "ddfips"
          ORDER BY UNACCENT("ddfips"."name") ASC,
                   "ddfips"."created_at" ASC
        SQL
      end

      it "orders DDFIPs by name in descendant order" do
        expect {
          described_class.order_by_param("-name").load
        }.to perform_sql_query(<<~SQL)
          SELECT   "ddfips".*
          FROM     "ddfips"
          ORDER BY UNACCENT("ddfips"."name") DESC,
                   "ddfips"."created_at" DESC
        SQL
      end

      it "orders DDFIPs by departement" do
        expect {
          described_class.order_by_param("departement").load
        }.to perform_sql_query(<<~SQL)
          SELECT   "ddfips".*
          FROM     "ddfips"
          ORDER BY "ddfips"."code_departement" ASC,
                   "ddfips"."created_at" ASC
        SQL
      end

      it "orders DDFIPs by departement in descendant order" do
        expect {
          described_class.order_by_param("-departement").load
        }.to perform_sql_query(<<~SQL)
          SELECT   "ddfips".*
          FROM     "ddfips"
          ORDER BY "ddfips"."code_departement" DESC,
                   "ddfips"."created_at" DESC
        SQL
      end

      it "orders DDFIPs by region" do
        expect {
          described_class.order_by_param("region").load
        }.to perform_sql_query(<<~SQL)
          SELECT          "ddfips".*
          FROM            "ddfips"
          LEFT OUTER JOIN "departements" ON "departements"."code_departement" = "ddfips"."code_departement"
          ORDER BY        "departements"."code_region" ASC,
                          "ddfips"."created_at" ASC
        SQL
      end

      it "orders DDFIPs by region in descendant order" do
        expect {
          described_class.order_by_param("-region").load
        }.to perform_sql_query(<<~SQL)
          SELECT          "ddfips".*
          FROM            "ddfips"
          LEFT OUTER JOIN "departements" ON "departements"."code_departement" = "ddfips"."code_departement"
          ORDER BY        "departements"."code_region" DESC,
                          "ddfips"."created_at" DESC
        SQL
      end
    end

    describe ".order_by_score" do
      it "orders DDFIPs by search score" do
        expect {
          described_class.order_by_score("Hello").load
        }.to perform_sql_query(<<~SQL)
          SELECT   "ddfips".*
          FROM     "ddfips"
          ORDER BY ts_rank_cd(to_tsvector('french', "ddfips"."name"), to_tsquery('french', 'Hello')) DESC,
                   "ddfips"."created_at" ASC
        SQL
      end
    end
  end

  # Other associations
  # ----------------------------------------------------------------------------
  describe "other associations" do
    describe "#on_territory_collectivities" do
      subject(:on_territory_collectivities) { ddfip.on_territory_collectivities }

      let(:ddfip) { create(:ddfip) }

      it { expect(on_territory_collectivities).to be_an(ActiveRecord::Relation) }
      it { expect(on_territory_collectivities.model).to eq(Collectivity) }

      it "loads the registered collectivities in the DDFIP departement" do
        expect { on_territory_collectivities.load }.to perform_sql_query(<<~SQL)
          SELECT "collectivities".*
          FROM   "collectivities"
          WHERE  "collectivities"."discarded_at" IS NULL
            AND (
                  "collectivities"."territory_type" = 'Commune'
              AND "collectivities"."territory_id" IN (
                    SELECT "communes"."id"
                    FROM   "communes"
                    WHERE  "communes"."code_departement" = '#{ddfip.code_departement}'
              )
              OR  "collectivities"."territory_type" = 'EPCI'
              AND "collectivities"."territory_id" IN (
                    SELECT     "epcis"."id"
                    FROM       "epcis"
                    INNER JOIN "communes" ON "communes"."siren_epci" = "epcis"."siren"
                    WHERE      "communes"."code_departement" = '#{ddfip.code_departement}'
              )
              OR  "collectivities"."territory_type" = 'Departement'
              AND "collectivities"."territory_id" IN (
                    SELECT "departements"."id"
                    FROM   "departements"
                    WHERE  "departements"."code_departement" = '#{ddfip.code_departement}'
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

      let!(:ddfips) { create_list(:ddfip, 2) }

      it { expect { reset_all_counters }.to perform_sql_query("SELECT reset_all_ddfips_counters()") }

      it "returns the count of DDFIPs" do
        expect(reset_all_counters).to eq(2)
      end

      describe "on users_count" do
        before do
          create_list(:user, 4, organization: ddfips[0])
          create_list(:user, 2, organization: ddfips[1])
          create_list(:user, 1, :publisher)
          create_list(:user, 1, :collectivity)

          DDFIP.update_all(users_count: 0)
        end

        it "resets counters" do
          expect { reset_all_counters }
            .to  change { ddfips[0].reload.users_count }.from(0).to(4)
            .and change { ddfips[1].reload.users_count }.from(0).to(2)
        end
      end

      describe "on collectivities_count" do
        before do
          epcis    = create_list(:epci, 3)
          communes =
            create_list(:commune, 3, epci: epcis[0], departement: ddfips[0].departement) +
            create_list(:commune, 2, epci: epcis[1], departement: ddfips[0].departement)

          create(:collectivity, territory: communes[0])
          create(:collectivity, territory: communes[1])
          create(:collectivity, territory: communes[3])
          create(:collectivity, :discarded, territory: communes[2])
          create(:collectivity, :discarded, territory: communes[4])
          create(:collectivity, :commune)
          create(:collectivity, territory: epcis[0])
          create(:collectivity, territory: epcis[1])
          create(:collectivity, territory: epcis[2])
          create(:collectivity, territory: ddfips[0].departement)
          create(:collectivity, territory: ddfips[1].departement.region)

          DDFIP.update_all(collectivities_count: 0)
        end

        it "resets counters" do
          expect { reset_all_counters }
            .to  change { ddfips[0].reload.collectivities_count }.from(0).to(6)
            .and change { ddfips[1].reload.collectivities_count }.from(0).to(1)
        end
      end

      describe "on offices_count" do
        before do
          create_list(:office, 4, ddfip: ddfips[0])
          create_list(:office, 2, ddfip: ddfips[1])
          create_list(:office, 1)

          DDFIP.update_all(offices_count: 0)
        end

        it "resets counters" do
          expect { reset_all_counters }
            .to  change { ddfips[0].reload.offices_count }.from(0).to(4)
            .and change { ddfips[1].reload.offices_count }.from(0).to(2)
        end
      end

      describe "on reports_count" do
        before do
          create_list(:commune, 4, code_departement: ddfips[0].code_departement)
          create_list(:commune, 2, code_departement: ddfips[1].code_departement)

          Commune.all.each { |commune| create(:report, :transmitted, commune: commune) }

          DDFIP.update_all(reports_count: 0)
        end

        it "resets counters" do
          expect { reset_all_counters }
            .to  change { ddfips[0].reload.reports_count }.from(0).to(4)
            .and change { ddfips[1].reload.reports_count }.from(0).to(2)
        end
      end

      describe "on reports_approved_count" do
        before do
          create_list(:commune, 4, code_departement: ddfips[0].code_departement)
          create_list(:commune, 2, code_departement: ddfips[1].code_departement)

          Commune.all.each { |commune| create(:report, :approved, commune: commune) }

          DDFIP.update_all(reports_approved_count: 0)
        end

        it "resets counters" do
          expect { reset_all_counters }
            .to  change { ddfips[0].reload.reports_approved_count }.from(0).to(4)
            .and change { ddfips[1].reload.reports_approved_count }.from(0).to(2)
        end
      end

      describe "on reports_rejected_count" do
        before do
          create_list(:commune, 4, code_departement: ddfips[0].code_departement)
          create_list(:commune, 2, code_departement: ddfips[1].code_departement)

          Commune.all.each { |commune| create(:report, :rejected, commune: commune) }

          DDFIP.update_all(reports_rejected_count: 0)
        end

        it "resets counters" do
          expect { reset_all_counters }
            .to  change { ddfips[0].reload.reports_rejected_count }.from(0).to(4)
            .and change { ddfips[1].reload.reports_rejected_count }.from(0).to(2)
        end
      end

      describe "on reports_debated_count" do
        before do
          create_list(:commune, 4, code_departement: ddfips[0].code_departement)
          create_list(:commune, 2, code_departement: ddfips[1].code_departement)

          Commune.all.each { |commune| create(:report, :debated, commune: commune) }

          DDFIP.update_all(reports_debated_count: 0)
        end

        it "resets counters" do
          expect { reset_all_counters }
            .to  change { ddfips[0].reload.reports_debated_count }.from(0).to(4)
            .and change { ddfips[1].reload.reports_debated_count }.from(0).to(2)
        end
      end
    end
  end

  # Database constraints and triggers
  # ----------------------------------------------------------------------------
  describe "database constraints" do
    it "asserts the uniqueness of name" do
      existing_ddfip = create(:ddfip)
      another_ddfip  = build(:ddfip, name: existing_ddfip.name)

      expect { another_ddfip.save(validate: false) }
        .to raise_error(ActiveRecord::RecordNotUnique).with_message(/PG::UniqueViolation/)
    end

    it "ignores discarded records when asserting the uniqueness of SIREN" do
      existing_ddfip = create(:ddfip, :discarded)
      another_ddfip  = build(:ddfip, name: existing_ddfip.name)

      expect { another_ddfip.save(validate: false) }
        .not_to raise_error
    end

    it "cannot destroy a departement referenced from ddfips" do
      departement = create(:departement)
      create(:ddfip, departement: departement)

      expect { departement.delete }
        .to raise_error(ActiveRecord::InvalidForeignKey).with_message(/PG::ForeignKeyViolation/)
    end
  end

  describe "database triggers" do
    let!(:ddfips) { create_list(:ddfip, 2) }

    describe "about organization counter caches" do
      describe "#users_count" do
        let(:user) { create(:user, organization: ddfips[0]) }

        it "changes on creation" do
          expect { user }
            .to change { ddfips[0].reload.users_count }.from(0).to(1)
            .and not_change { ddfips[1].reload.users_count }.from(0)
        end

        it "changes on deletion" do
          user
          expect { user.destroy }
            .to change { ddfips[0].reload.users_count }.from(1).to(0)
            .and not_change { ddfips[1].reload.users_count }.from(0)
        end

        it "changes when discarding" do
          user
          expect { user.discard }
            .to change { ddfips[0].reload.users_count }.from(1).to(0)
            .and not_change { ddfips[1].reload.users_count }.from(0)
        end

        it "changes when undiscarding" do
          user.discard
          expect { user.undiscard }
            .to change { ddfips[0].reload.users_count }.from(0).to(1)
            .and not_change { ddfips[1].reload.users_count }.from(0)
        end

        it "changes when updating organization" do
          user
          expect { user.update(organization: ddfips[1]) }
            .to  change { ddfips[0].reload.users_count }.from(1).to(0)
            .and change { ddfips[1].reload.users_count }.from(0).to(1)
        end
      end

      describe "#collectivities_count" do
        let(:communes) do
          [
            create(:commune, :with_epci, departement: ddfips[0].departement),
            create(:commune, :with_epci, departement: ddfips[1].departement)
          ]
        end

        context "with communes" do
          it_behaves_like "it changes collectivities count" do
            let(:subjects)    { ddfips }
            let(:territories) { communes }
          end
        end

        context "with EPCIs having communes in the departements" do
          it_behaves_like "it changes collectivities count" do
            let(:subjects)    { ddfips }
            let(:territories) { communes.map(&:epci) }
          end
        end

        context "with an EPCI belonging to the departement but without communes in it" do
          let(:epci)         { create(:epci, departement: ddfips[0].departement) }
          let(:collectivity) { create(:collectivity, territory: epci) }

          it do
            expect { collectivity }
              .to  not_change { ddfips[0].reload.collectivities_count }.from(0)
              .and not_change { ddfips[1].reload.collectivities_count }.from(0)
          end
        end

        context "with departements" do
          it_behaves_like "it changes collectivities count" do
            let(:subjects)    { ddfips }
            let(:territories) { communes.map(&:departement) }
          end
        end

        context "with regions" do
          it_behaves_like "it changes collectivities count" do
            let(:subjects)    { ddfips }
            let(:territories) { communes.map(&:region) }
          end
        end
      end

      describe "#offices_count" do
        let(:office) { create(:office, ddfip: ddfips[0]) }

        it "changes on creation" do
          expect { office }
            .to change { ddfips[0].reload.offices_count }.from(0).to(1)
            .and not_change { ddfips[1].reload.offices_count }.from(0)
        end

        it "changes on deletion" do
          office
          expect { office.destroy }
            .to change { ddfips[0].reload.offices_count }.from(1).to(0)
            .and not_change { ddfips[1].reload.offices_count }.from(0)
        end

        it "changes on updating" do
          office
          expect { office.update(ddfip: ddfips[1]) }
            .to  change { ddfips[0].reload.offices_count }.from(1).to(0)
            .and change { ddfips[1].reload.offices_count }.from(0).to(1)
        end
      end
    end

    describe "about reports counter caches" do
      describe "#reports_count" do
        before do
          commune = create(:commune)
          ddfips.first.update(code_departement: commune.code_departement)
        end

        let(:commune) { Commune.first }
        let(:report) { create(:report, commune: commune) }

        it "doesn't change on report creation" do
          expect { report }
            .to  not_change { ddfips[0].reload.reports_count }.from(0)
            .and not_change { ddfips[1].reload.reports_count }.from(0)
        end

        it "changes when package is transmitted" do
          report

          expect { report.package.transmit! }
            .to change { ddfips[0].reload.reports_count }.from(0).to(1)
            .and not_change { ddfips[1].reload.reports_count }.from(0)
        end

        it "doesn't changes when package in sandbox is transmitted" do
          report.package.update(sandbox: true)

          expect { report.package.transmit! }
            .to  not_change { ddfips[0].reload.reports_count }.from(0)
            .and not_change { ddfips[1].reload.reports_count }.from(0)
        end

        it "changes when transmitted report is discarded" do
          report.package.touch(:transmitted_at)

          expect { report.discard }
            .to change { ddfips[0].reload.reports_count }.from(1).to(0)
            .and not_change { ddfips[1].reload.reports_count }.from(0)
        end

        it "changes when transmitted report is undiscarded" do
          report.discard and report.package.transmit!

          expect { report.undiscard }
            .to change { ddfips[0].reload.reports_count }.from(0).to(1)
            .and not_change { ddfips[1].reload.reports_count }.from(0)
        end

        it "changes when transmitted report is deleted" do
          report.package.transmit!

          expect { report.destroy }
            .to change { ddfips[0].reload.reports_count }.from(1).to(0)
            .and not_change { ddfips[1].reload.reports_count }.from(0)
        end

        it "changes when transmitted package is discarded" do
          report.package.transmit!

          expect { report.package.discard }
            .to change { ddfips[0].reload.reports_count }.from(1).to(0)
            .and not_change { ddfips[1].reload.reports_count }.from(0)
        end

        it "changes when transmitted package is undiscarded" do
          report.package.touch(:transmitted_at, :discarded_at)

          expect { report.package.undiscard }
            .to change { ddfips[0].reload.reports_count }.from(0).to(1)
            .and not_change { ddfips[1].reload.reports_count }.from(0)
        end

        it "changes when transmitted package is deleted" do
          report.package.transmit!

          expect { report.package.delete }
            .to change { ddfips[0].reload.reports_count }.from(1).to(0)
            .and not_change { ddfips[1].reload.reports_count }.from(0)
        end
      end

      describe "#reports_approved_count" do
        before do
          commune = create(:commune)
          ddfips.first.update(code_departement: commune.code_departement)
        end

        let(:commune) { Commune.first }
        let(:report) { create(:report, commune: commune) }

        it "doesn't change on report creation" do
          expect { report }
            .to  not_change { ddfips[0].reload.reports_approved_count }.from(0)
            .and not_change { ddfips[1].reload.reports_approved_count }.from(0)
        end

        it "changes when transmitted report is approved" do
          report.package.touch(:transmitted_at)

          expect { report.approve! }
            .to change { ddfips[0].reload.reports_approved_count }.from(0).to(1)
            .and not_change { ddfips[1].reload.reports_approved_count }.from(0)
        end

        it "changes when approved and transmitted report is discarded" do
          report.approve! and report.package.touch(:transmitted_at)

          expect { report.discard }
            .to change { ddfips[0].reload.reports_approved_count }.from(1).to(0)
            .and not_change { ddfips[1].reload.reports_approved_count }.from(0)
        end

        it "changes when approved and transmitted report is undiscarded" do
          report.touch(:approved_at, :discarded_at) and report.package.touch(:transmitted_at)

          expect { report.undiscard }
            .to change { ddfips[0].reload.reports_approved_count }.from(0).to(1)
            .and not_change { ddfips[1].reload.reports_approved_count }.from(0)
        end

        it "changes when approved and transmitted report is deleted" do
          report.touch(:approved_at) and report.package.touch(:transmitted_at)

          expect { report.delete }
            .to change { ddfips[0].reload.reports_approved_count }.from(1).to(0)
            .and not_change { ddfips[1].reload.reports_approved_count }.from(0)
        end
      end

      describe "#reports_rejected_count" do
        before do
          commune = create(:commune)
          ddfips.first.update(code_departement: commune.code_departement)
        end

        let(:commune) { Commune.first }
        let(:report) { create(:report, commune: commune) }

        it "doesn't change on report creation" do
          expect { report }
            .to  not_change { ddfips[0].reload.reports_rejected_count }.from(0)
            .and not_change { ddfips[1].reload.reports_rejected_count }.from(0)
        end

        it "changes when transmitted report is rejected" do
          report.package.touch(:transmitted_at)

          expect { report.reject! }
            .to change { ddfips[0].reload.reports_rejected_count }.from(0).to(1)
            .and not_change { ddfips[1].reload.reports_rejected_count }.from(0)
        end

        it "changes when rejected and transmitted report is discarded" do
          report.reject! and report.package.touch(:transmitted_at)

          expect { report.discard }
            .to change { ddfips[0].reload.reports_rejected_count }.from(1).to(0)
            .and not_change { ddfips[1].reload.reports_rejected_count }.from(0)
        end

        it "changes when rejected and transmitted report is undiscarded" do
          report.touch(:rejected_at, :discarded_at) and report.package.touch(:transmitted_at)

          expect { report.undiscard }
            .to change { ddfips[0].reload.reports_rejected_count }.from(0).to(1)
            .and not_change { ddfips[1].reload.reports_rejected_count }.from(0)
        end

        it "changes when rejected and transmitted report is deleted" do
          report.touch(:rejected_at) and report.package.touch(:transmitted_at)

          expect { report.delete }
            .to change { ddfips[0].reload.reports_rejected_count }.from(1).to(0)
            .and not_change { ddfips[1].reload.reports_rejected_count }.from(0)
        end
      end

      describe "#reports_debated_count" do
        before do
          commune = create(:commune)
          ddfips.first.update(code_departement: commune.code_departement)
        end

        let(:commune) { Commune.first }
        let(:report) { create(:report, commune: commune) }

        it "doesn't change on report creation" do
          expect { report }
            .to  not_change { ddfips[0].reload.reports_debated_count }.from(0)
            .and not_change { ddfips[1].reload.reports_debated_count }.from(0)
        end

        it "changes when transmitted report is marked as debated" do
          report.package.touch(:transmitted_at)

          expect { report.debate! }
            .to change { ddfips[0].reload.reports_debated_count }.from(0).to(1)
            .and not_change { ddfips[1].reload.reports_debated_count }.from(0)
        end

        it "changes when debated and transmitted report is discarded" do
          report.debate! and report.package.touch(:transmitted_at)

          expect { report.discard }
            .to change { ddfips[0].reload.reports_debated_count }.from(1).to(0)
            .and not_change { ddfips[1].reload.reports_debated_count }.from(0)
        end

        it "changes when debated and transmitted report is undiscarded" do
          report.touch(:debated_at, :discarded_at) and report.package.touch(:transmitted_at)

          expect { report.undiscard }
            .to change { ddfips[0].reload.reports_debated_count }.from(0).to(1)
            .and not_change { ddfips[1].reload.reports_debated_count }.from(0)
        end

        it "changes when debated and transmitted report is deleted" do
          report.touch(:debated_at) and report.package.touch(:transmitted_at)

          expect { report.delete }
            .to change { ddfips[0].reload.reports_debated_count }.from(1).to(0)
            .and not_change { ddfips[1].reload.reports_debated_count }.from(0)
        end
      end

      describe "#reports_pending_count" do
        before do
          commune = create(:commune)
          ddfips.first.update(code_departement: commune.code_departement)
        end

        let(:commune) { Commune.first }
        let(:report) { create(:report, :transmitted, commune: commune) }

        it "change on report creation" do
          expect { report }
            .to  change { ddfips[0].reload.reports_pending_count }.from(0).to(1)
            .and not_change { ddfips[1].reload.reports_pending_count }.from(0)
        end

        it "changes when report is approved" do
          report

          expect { report.approve! }
            .to change { ddfips[0].reload.reports_pending_count }.from(1).to(0)
            .and not_change { ddfips[1].reload.reports_pending_count }.from(0)
        end

        it "changes when report is discarded" do
          report

          expect { report.discard }
            .to change { ddfips[0].reload.reports_pending_count }.from(1).to(0)
            .and not_change { ddfips[1].reload.reports_pending_count }.from(0)
        end

        it "changes when report is undiscarded" do
          report.discard

          expect { report.undiscard }
            .to change { ddfips[0].reload.reports_pending_count }.from(0).to(1)
            .and not_change { ddfips[1].reload.reports_pending_count }.from(0)
        end

        it "changes when report is deleted" do
          report

          expect { report.delete }
            .to change { ddfips[0].reload.reports_pending_count }.from(1).to(0)
            .and not_change { ddfips[1].reload.reports_pending_count }.from(0)
        end
      end
    end
  end
end
