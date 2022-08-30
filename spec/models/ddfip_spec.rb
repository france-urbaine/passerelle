# frozen_string_literal: true

require "rails_helper"

RSpec.describe DDFIP, type: :model do
  # Associations
  # ----------------------------------------------------------------------------
  it { is_expected.to belong_to(:departement).required }
  it { is_expected.to have_many(:epcis) }
  it { is_expected.to have_many(:communes) }
  it { is_expected.to have_one(:region) }
  it { is_expected.to have_many(:users) }

  # Validations
  # ----------------------------------------------------------------------------
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
        .and exclude(pyrenees_atlantiques)
        .and exclude(paris)
    end

    it do
      expect(described_class.search("Pyrénées"))
        .to  include(pyrenees_atlantiques)
        .and exclude(nord)
        .and exclude(paris)
    end

    it do
      expect(described_class.search("Aquitaine"))
        .to  include(pyrenees_atlantiques)
        .and exclude(nord)
        .and exclude(paris)
    end

    it do
      expect(described_class.search("75"))
        .to  include(paris)
        .and exclude(nord)
        .and exclude(pyrenees_atlantiques)
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

  # Other associations
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

  # Counter caches
  # ----------------------------------------------------------------------------
  describe "counter caches" do
    let!(:ddfip1) { create(:ddfip) }
    let!(:ddfip2) { create(:ddfip) }

    describe "#users_count" do
      let(:user) { create(:user, organization: ddfip1) }

      it "changes on creation" do
        expect { user }
          .to      change { ddfip1.reload.users_count }.from(0).to(1)
          .and not_change { ddfip2.reload.users_count }.from(0)
      end

      it "changes on deletion" do
        user
        expect { user.destroy }
          .to      change { ddfip1.reload.users_count }.from(1).to(0)
          .and not_change { ddfip2.reload.users_count }.from(0)
      end

      it "changes on updating" do
        user
        expect { user.update(organization: ddfip2) }
          .to  change { ddfip1.reload.users_count }.from(1).to(0)
          .and change { ddfip2.reload.users_count }.from(0).to(1)
      end
    end

    describe "#collectivities_count" do
      shared_examples "trigger changes" do
        let(:collectivity) { create(:collectivity, territory: territory1) }

        it "changes on creation" do
          expect { collectivity }
            .to      change { ddfip1.reload.collectivities_count }.from(0).to(1)
            .and not_change { ddfip2.reload.collectivities_count }.from(0)
        end

        it "changes on discarding" do
          collectivity
          expect { collectivity.discard }
            .to      change { ddfip1.reload.collectivities_count }.from(1).to(0)
            .and not_change { ddfip2.reload.collectivities_count }.from(0)
        end

        it "changes on undiscarding" do
          collectivity.discard
          expect { collectivity.undiscard }
            .to      change { ddfip1.reload.collectivities_count }.from(0).to(1)
            .and not_change { ddfip2.reload.collectivities_count }.from(0)
        end

        it "changes on deletion" do
          collectivity
          expect { collectivity.destroy }
            .to      change { ddfip1.reload.collectivities_count }.from(1).to(0)
            .and not_change { ddfip2.reload.collectivities_count }.from(0)
        end

        it "doesn't change when deleting a discarded collectivity" do
          collectivity.discard
          expect { collectivity.destroy }
            .to  not_change { ddfip1.reload.collectivities_count }.from(0)
            .and not_change { ddfip2.reload.collectivities_count }.from(0)
        end

        it "changes when updating territory" do
          collectivity
          expect { collectivity.update(territory: territory2) }
            .to  change { ddfip1.reload.collectivities_count }.from(1).to(0)
            .and change { ddfip2.reload.collectivities_count }.from(0).to(1)
        end

        it "doesn't change when updating territory of a discarded collectivity" do
          collectivity.discard
          expect { collectivity.update(territory: territory2) }
            .to  not_change { ddfip1.reload.collectivities_count }.from(0)
            .and not_change { ddfip2.reload.collectivities_count }.from(0)
        end

        it "changes when combining updating territory and discarding" do
          collectivity
          expect { collectivity.update(territory: territory2, discarded_at: Time.current) }
            .to      change { ddfip1.reload.collectivities_count }.from(1).to(0)
            .and not_change { ddfip2.reload.collectivities_count }.from(0)
        end

        it "changes when combining updating territory and undiscarding" do
          collectivity.discard
          expect { collectivity.update(territory: territory2, discarded_at: nil) }
            .to  not_change { ddfip1.reload.collectivities_count }.from(0)
            .and     change { ddfip2.reload.collectivities_count }.from(0).to(1)
        end
      end

      context "with a commune" do
        let(:territory1) { create(:commune, departement: ddfip1.departement) }
        let(:territory2) { create(:commune, departement: ddfip2.departement) }

        include_examples "trigger changes"
      end

      context "with an EPCI having a commune in departement" do
        let(:territory1) { create(:commune, :with_epci, departement: ddfip1.departement).epci }
        let(:territory2) { create(:commune, :with_epci, departement: ddfip2.departement).epci }

        include_examples "trigger changes"
      end

      context "with an EPCI belonging to departement, without communes in it" do
        let(:territory)    { create(:epci, departement: ddfip1.departement) }
        let(:collectivity) { create(:collectivity, territory: territory) }

        it do
          expect { collectivity }
            .to  not_change { ddfip1.reload.collectivities_count }.from(0)
            .and not_change { ddfip2.reload.collectivities_count }.from(0)
        end
      end

      context "with a departement" do
        let(:territory1) { ddfip1.departement }
        let(:territory2) { ddfip2.departement }

        include_examples "trigger changes"
      end

      context "with a region" do
        let(:territory1) { ddfip1.departement.region }
        let(:territory2) { ddfip2.departement.region }

        include_examples "trigger changes"
      end
    end
  end

  # Reset counters
  # ----------------------------------------------------------------------------
  describe ".reset_all_counters" do
    subject { described_class.reset_all_counters }

    let!(:ddfip1) { create(:ddfip) }
    let!(:ddfip2) { create(:ddfip) }

    describe "on users_count" do
      before do
        create_list(:user, 4, organization: ddfip1)
        create_list(:user, 2, organization: ddfip2)
        create_list(:user, 1, :publisher)
        create_list(:user, 1, :collectivity)

        DDFIP.update_all(users_count: 0)
      end

      its_block { is_expected.to change { ddfip1.reload.users_count }.from(0).to(4) }
      its_block { is_expected.to change { ddfip2.reload.users_count }.from(0).to(2) }
    end

    describe "on collectivities_count" do
      before do
        epcis    = create_list(:epci, 3)
        communes =
          create_list(:commune, 3, epci: epcis[0], departement: ddfip1.departement) +
          create_list(:commune, 2, epci: epcis[1], departement: ddfip1.departement)

        create(:collectivity, territory: communes[0])
        create(:collectivity, territory: communes[1])
        create(:collectivity, territory: communes[3])
        create(:collectivity, :discarded, territory: communes[2])
        create(:collectivity, :discarded, territory: communes[4])
        create(:collectivity, :commune)
        create(:collectivity, territory: epcis[0])
        create(:collectivity, territory: epcis[1])
        create(:collectivity, territory: epcis[2])
        create(:collectivity, territory: ddfip1.departement)
        create(:collectivity, territory: ddfip2.departement.region)

        DDFIP.update_all(collectivities_count: 0)
      end

      it        { is_expected.to eq(2) }
      its_block { is_expected.to change { ddfip1.reload.collectivities_count }.from(0).to(6) }
      its_block { is_expected.to change { ddfip2.reload.collectivities_count }.from(0).to(1) }
    end

    its_block do
      is_expected.to perform_sql_query(<<~SQL.squish)
        SELECT reset_all_ddfips_counters()
      SQL
    end
  end
end
