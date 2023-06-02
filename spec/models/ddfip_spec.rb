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

    context "with an existing DDFIP" do
      # FYI: About uniqueness validations, case insensitivity and accents:
      # You should read ./docs/uniqueness_validations_and_accents.md
      before { create(:ddfip) }

      it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
    end

    context "when existing collectivity is discarded" do
      before { create(:ddfip, :discarded) }

      it { is_expected.not_to validate_uniqueness_of(:name).case_insensitive }
    end
  end

  # Search
  # ----------------------------------------------------------------------------
  describe ".search" do
    let(:nord)                 { create(:ddfip, code_departement: 59, name: "DDFIP du Nord") }
    let(:pyrenees_atlantiques) { create(:ddfip, code_departement: 64, name: "DDFIP des PA") }
    let(:paris)                { create(:ddfip, code_departement: 75, name: "DDFIP de Paris") }

    before do
      create(:region, code_region: 11, name: "Ile-de-France")
      create(:region, code_region: 75, name: "Nouvelle-Aquitaine")
      create(:region, code_region: 32, name: "Hauts-de-France")

      create(:departement, code_departement: 75, code_region: 11, name: "Paris")
      create(:departement, code_departement: 64, code_region: 75, name: "Pyrénées-Atlantiques")
      create(:departement, code_departement: 59, code_region: 32, name: "Nord")
    end

    it do
      expect(described_class.search("DDFIP du Nord"))
        .to  include(nord)
        .and not_include(pyrenees_atlantiques)
        .and not_include(paris)
    end

    it do
      expect(described_class.search("Pyrénées"))
        .to  include(pyrenees_atlantiques)
        .and not_include(nord)
        .and not_include(paris)
    end

    it do
      expect(described_class.search("Aquitaine"))
        .to  include(pyrenees_atlantiques)
        .and not_include(nord)
        .and not_include(paris)
    end

    it do
      expect(described_class.search("75"))
        .to  include(paris)
        .and not_include(nord)
        .and not_include(pyrenees_atlantiques)
    end

    it do
      expect { described_class.search("Hello").load }.to perform_sql_query(<<~SQL.squish)
        SELECT          "ddfips".*
        FROM            "ddfips"
        LEFT OUTER JOIN "departements" ON "departements"."code_departement" = "ddfips"."code_departement"
        LEFT OUTER JOIN "regions" ON "regions"."code_region" = "departements"."code_region"
        WHERE (LOWER(UNACCENT("ddfips"."name")) LIKE LOWER(UNACCENT('%Hello%'))
          OR "ddfips"."code_departement" = 'Hello'
          OR LOWER(UNACCENT("departements"."name")) LIKE LOWER(UNACCENT('%Hello%'))
          OR LOWER(UNACCENT("regions"."name"))      LIKE LOWER(UNACCENT('%Hello%')))
      SQL
    end
  end

  # Database queries
  # ----------------------------------------------------------------------------
  describe "#on_territory_collectivities" do
    let(:ddfip) { create(:ddfip) }

    it do
      expect { ddfip.on_territory_collectivities.load }.to perform_sql_query(<<~SQL)
        SELECT "collectivities".*
        FROM   "collectivities"
        WHERE  "collectivities"."discarded_at" IS NULL
          AND (
                "collectivities"."territory_type" = 'Commune'
            AND "collectivities"."territory_id" IN (
                  SELECT "communes"."id"
                  FROM "communes"
                  WHERE "communes"."code_departement" = '#{ddfip.code_departement}'
            )
            OR  "collectivities"."territory_type" = 'EPCI'
            AND "collectivities"."territory_id" IN (
                  SELECT "epcis"."id"
                  FROM "epcis"
                  INNER JOIN "communes" ON "communes"."siren_epci" = "epcis"."siren"
                  WHERE "communes"."code_departement" = '#{ddfip.code_departement}'
            )
            OR  "collectivities"."territory_type" = 'Departement'
            AND "collectivities"."territory_id" IN (
              SELECT "departements"."id"
              FROM "departements"
              WHERE "departements"."code_departement" = '#{ddfip.code_departement}'
            )
          )
      SQL
    end
  end

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
  end

  # Database constraints and triggers
  # ----------------------------------------------------------------------------
  describe "database constraints" do
    pending "TODO"
  end

  describe "database triggers" do
    let!(:ddfips) { create_list(:ddfip, 2) }

    describe "#users_count" do
      let(:user) { create(:user, organization: ddfips[0]) }

      it "changes on creation" do
        expect { user }
          .to      change { ddfips[0].reload.users_count }.from(0).to(1)
          .and not_change { ddfips[1].reload.users_count }.from(0)
      end

      it "changes on deletion" do
        user
        expect { user.destroy }
          .to      change { ddfips[0].reload.users_count }.from(1).to(0)
          .and not_change { ddfips[1].reload.users_count }.from(0)
      end

      it "changes when discarding" do
        user
        expect { user.discard }
          .to      change { ddfips[0].reload.users_count }.from(1).to(0)
          .and not_change { ddfips[1].reload.users_count }.from(0)
      end

      it "changes when undiscarding" do
        user.discard
        expect { user.undiscard }
          .to      change { ddfips[0].reload.users_count }.from(0).to(1)
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
          .to      change { ddfips[0].reload.offices_count }.from(0).to(1)
          .and not_change { ddfips[1].reload.offices_count }.from(0)
      end

      it "changes on deletion" do
        office
        expect { office.destroy }
          .to      change { ddfips[0].reload.offices_count }.from(1).to(0)
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
end
