# frozen_string_literal: true

require "rails_helper"

RSpec.describe Organization::CollectivityPolicy, type: :policy do
  describe_rule :index? do
    let(:record) { Collectivity }

    it_behaves_like("when current user is a DDFIP super admin")        { failed }
    it_behaves_like("when current user is a DDFIP admin")              { succeed }
    it_behaves_like("when current user is a DDFIP user")               { failed }
    it_behaves_like("when current user is a publisher super admin")    { succeed }
    it_behaves_like("when current user is a publisher admin")          { succeed }
    it_behaves_like("when current user is a publisher user")           { succeed }
    it_behaves_like("when current user is a collectivity super admin") { failed }
    it_behaves_like("when current user is a collectivity admin")       { failed }
    it_behaves_like("when current user is a collectivity user")        { failed }
  end

  describe_rule :show? do
    context "without record" do
      let(:record) { Collectivity }

      it_behaves_like("when current user is a DDFIP super admin")        { failed }
      it_behaves_like("when current user is a DDFIP admin")              { succeed }
      it_behaves_like("when current user is a DDFIP user")               { failed }
      it_behaves_like("when current user is a publisher super admin")    { succeed }
      it_behaves_like("when current user is a publisher admin")          { succeed }
      it_behaves_like("when current user is a publisher user")           { succeed }
      it_behaves_like("when current user is a collectivity super admin") { failed }
      it_behaves_like("when current user is a collectivity admin")       { failed }
      it_behaves_like("when current user is a collectivity user")        { failed }
    end

    context "with a collectivity" do
      let(:record) { build_stubbed(:collectivity) }

      it_behaves_like("when current user is a DDFIP super admin")        { failed }
      it_behaves_like("when current user is a DDFIP admin")              { failed }
      it_behaves_like("when current user is a DDFIP user")               { failed }
      it_behaves_like("when current user is a publisher super admin")    { failed }
      it_behaves_like("when current user is a publisher admin")          { failed }
      it_behaves_like("when current user is a publisher user")           { failed }
      it_behaves_like("when current user is a collectivity super admin") { failed }
      it_behaves_like("when current user is a collectivity admin")       { failed }
      it_behaves_like("when current user is a collectivity user")        { failed }
    end

    context "with the same collectivity as the current organization" do
      let(:record) { current_organization }

      it_behaves_like("when current user is a collectivity super admin") { failed }
      it_behaves_like("when current user is a collectivity admin")       { failed }
      it_behaves_like("when current user is a collectivity user")        { failed }
    end

    context "with a collectivity owned by the current publisher" do
      let(:record) { build_stubbed(:collectivity, publisher: current_organization) }

      it_behaves_like("when current user is a publisher super admin") { succeed }
      it_behaves_like("when current user is a publisher admin")       { succeed }
      it_behaves_like("when current user is a publisher user")        { succeed }
    end

    context "with a collectivity owned and allowed to be managed by the current publisher" do
      let(:record) { build_stubbed(:collectivity, publisher: current_organization, allow_publisher_management: true) }

      it_behaves_like("when current user is a publisher super admin") { succeed }
      it_behaves_like("when current user is a publisher admin")       { succeed }
      it_behaves_like("when current user is a publisher user")        { succeed }
    end

    context "with a collectivity which is likely to send reports to the current DDFIP", stub_factories: false do
      let(:commune) { create(:commune, departement: current_organization.departement) }
      let(:record)  { create(:collectivity, territory: commune) }

      it_behaves_like("when current user is a DDFIP super admin") { failed }
      it_behaves_like("when current user is a DDFIP admin")       { succeed }
      it_behaves_like("when current user is a DDFIP user")        { failed }
    end
  end

  describe_rule :manage? do
    context "without record" do
      let(:record) { Collectivity }

      it_behaves_like("when current user is a DDFIP super admin")        { failed }
      it_behaves_like("when current user is a DDFIP admin")              { failed }
      it_behaves_like("when current user is a DDFIP user")               { failed }
      it_behaves_like("when current user is a publisher super admin")    { succeed }
      it_behaves_like("when current user is a publisher admin")          { succeed }
      it_behaves_like("when current user is a publisher user")           { succeed }
      it_behaves_like("when current user is a collectivity super admin") { failed }
      it_behaves_like("when current user is a collectivity admin")       { failed }
      it_behaves_like("when current user is a collectivity user")        { failed }
    end

    context "with a collectivity" do
      let(:record) { build_stubbed(:collectivity) }

      it_behaves_like("when current user is a DDFIP super admin")        { failed }
      it_behaves_like("when current user is a DDFIP admin")              { failed }
      it_behaves_like("when current user is a DDFIP user")               { failed }
      it_behaves_like("when current user is a publisher super admin")    { failed }
      it_behaves_like("when current user is a publisher admin")          { failed }
      it_behaves_like("when current user is a publisher user")           { failed }
      it_behaves_like("when current user is a collectivity super admin") { failed }
      it_behaves_like("when current user is a collectivity admin")       { failed }
      it_behaves_like("when current user is a collectivity user")        { failed }
    end

    context "with the same collectivity as the current organization" do
      let(:record) { current_organization }

      it_behaves_like("when current user is a collectivity super admin") { failed }
      it_behaves_like("when current user is a collectivity admin")       { failed }
      it_behaves_like("when current user is a collectivity user")        { failed }
    end

    context "with a collectivity owned by the current publisher" do
      let(:record) { build_stubbed(:collectivity, publisher: current_organization) }

      it_behaves_like("when current user is a publisher super admin") { failed }
      it_behaves_like("when current user is a publisher admin")       { failed }
      it_behaves_like("when current user is a publisher user")        { failed }
    end

    context "with a collectivity owned and allowed to be managed by the current publisher" do
      let(:record) { build_stubbed(:collectivity, publisher: current_organization, allow_publisher_management: true) }

      it_behaves_like("when current user is a publisher super admin") { succeed }
      it_behaves_like("when current user is a publisher admin")       { succeed }
      it_behaves_like("when current user is a publisher user")        { succeed }
    end
  end

  it { expect(:new?).to           be_an_alias_of(policy, :manage?) }
  it { expect(:create?).to        be_an_alias_of(policy, :manage?) }
  it { expect(:edit?).to          be_an_alias_of(policy, :manage?) }
  it { expect(:update?).to        be_an_alias_of(policy, :manage?) }
  it { expect(:remove?).to        be_an_alias_of(policy, :manage?) }
  it { expect(:destroy?).to       be_an_alias_of(policy, :manage?) }
  it { expect(:undiscard?).to     be_an_alias_of(policy, :manage?) }
  it { expect(:remove_all?).to    be_an_alias_of(policy, :manage?) }
  it { expect(:destroy_all?).to   be_an_alias_of(policy, :manage?) }
  it { expect(:undiscard_all?).to be_an_alias_of(policy, :manage?) }

  describe "default relation scope" do
    subject(:scope) { apply_relation_scope(Collectivity.all) }

    it_behaves_like "when current user is a publisher super admin" do
      it "scopes all kept collectivities" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "collectivities".*
          FROM   "collectivities"
          WHERE  "collectivities"."discarded_at" IS NULL
            AND  "collectivities"."publisher_id" = '#{current_organization.id}'
        SQL
      end
    end

    it_behaves_like "when current user is a publisher admin" do
      it "scopes all kept collectivities belonging to publisher" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "collectivities".*
          FROM   "collectivities"
          WHERE  "collectivities"."discarded_at" IS NULL
            AND  "collectivities"."publisher_id" = '#{current_organization.id}'
        SQL
      end
    end

    it_behaves_like "when current user is a publisher user" do
      it "scopes all kept collectivities belonging to publisher" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "collectivities".*
          FROM   "collectivities"
          WHERE  "collectivities"."discarded_at" IS NULL
            AND  "collectivities"."publisher_id" = '#{current_organization.id}'
        SQL
      end
    end

    it_behaves_like "when current user is a DDFIP admin" do
      it "scopes all kept collectivities on its territory" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "collectivities".*
          FROM   "collectivities"
          WHERE  "collectivities"."discarded_at" IS NULL
            AND (
                  "collectivities"."territory_type" = 'Commune'
              AND "collectivities"."territory_id" IN (
                    SELECT "communes"."id"
                    FROM   "communes"
                    WHERE  "communes"."code_departement" = '#{current_organization.code_departement}'
              )
              OR  "collectivities"."territory_type" = 'EPCI'
              AND "collectivities"."territory_id" IN (
                    SELECT     "epcis"."id"
                    FROM       "epcis"
                    INNER JOIN "communes" ON "communes"."siren_epci" = "epcis"."siren"
                    WHERE      "communes"."code_departement" = '#{current_organization.code_departement}'
              )
              OR  "collectivities"."territory_type" = 'Departement'
              AND "collectivities"."territory_id" IN (
                    SELECT "departements"."id"
                    FROM   "departements"
                    WHERE  "departements"."code_departement" = '#{current_organization.code_departement}'
              )
            )
        SQL
      end
    end

    it_behaves_like("when current user is a DDFIP super admin")        { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a DDFIP user")               { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a collectivity super admin") { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a collectivity admin")       { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a collectivity user")        { it { is_expected.to be_a_null_relation } }
  end

  describe "destroyable relation scope" do
    subject(:scope) { apply_relation_scope(Collectivity.all, name: :destroyable) }

    it_behaves_like "when current user is a publisher super admin" do
      it "scopes all kept collectivities" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "collectivities".*
          FROM   "collectivities"
          WHERE  "collectivities"."discarded_at" IS NULL
            AND  "collectivities"."publisher_id" = '#{current_organization.id}'
            AND  "collectivities"."allow_publisher_management" = TRUE
        SQL
      end
    end

    it_behaves_like "when current user is a publisher admin" do
      it "scopes all kept collectivities belonging to publisher" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "collectivities".*
          FROM   "collectivities"
          WHERE  "collectivities"."discarded_at" IS NULL
            AND  "collectivities"."publisher_id" = '#{current_organization.id}'
            AND  "collectivities"."allow_publisher_management" = TRUE
        SQL
      end
    end

    it_behaves_like "when current user is a publisher user" do
      it "scopes all kept collectivities belonging to publisher" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "collectivities".*
          FROM   "collectivities"
          WHERE  "collectivities"."discarded_at" IS NULL
            AND  "collectivities"."publisher_id" = '#{current_organization.id}'
            AND  "collectivities"."allow_publisher_management" = TRUE
        SQL
      end
    end

    it_behaves_like("when current user is a DDFIP super admin")        { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a DDFIP admin")              { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a DDFIP user")               { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a collectivity super admin") { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a collectivity admin")       { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a collectivity user")        { it { is_expected.to be_a_null_relation } }
  end

  describe "undiscardable relation scope" do
    subject(:scope) { apply_relation_scope(Collectivity.all, name: :undiscardable) }

    it_behaves_like "when current user is a publisher super admin" do
      it "scopes all kept collectivities" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "collectivities".*
          FROM   "collectivities"
          WHERE  "collectivities"."publisher_id" = '#{current_organization.id}'
            AND  "collectivities"."allow_publisher_management" = TRUE
            AND  "collectivities"."discarded_at" IS NOT NULL
        SQL
      end
    end

    it_behaves_like "when current user is a publisher admin" do
      it "scopes all kept collectivities belonging to publisher" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "collectivities".*
          FROM   "collectivities"
          WHERE  "collectivities"."publisher_id" = '#{current_organization.id}'
            AND  "collectivities"."allow_publisher_management" = TRUE
            AND  "collectivities"."discarded_at" IS NOT NULL
        SQL
      end
    end

    it_behaves_like "when current user is a publisher user" do
      it "scopes all kept collectivities belonging to publisher" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "collectivities".*
          FROM   "collectivities"
          WHERE  "collectivities"."publisher_id" = '#{current_organization.id}'
            AND  "collectivities"."allow_publisher_management" = TRUE
            AND  "collectivities"."discarded_at" IS NOT NULL
        SQL
      end
    end

    it_behaves_like("when current user is a DDFIP super admin")        { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a DDFIP admin")              { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a DDFIP user")               { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a collectivity super admin") { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a collectivity admin")       { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a collectivity user")        { it { is_expected.to be_a_null_relation } }
  end

  describe "params scope" do
    subject(:params) { apply_params_scope(attributes) }

    let(:attributes) do
      {
        publisher_id:        "f4e6854a-00fb-48c4-b669-5f0623e07778",
        territory_type:      "EPCI",
        territory_id:        "738569d4-1761-4a99-8bbc-7f40aa243fce",
        territory_data:      { type: "EPCI", id: "738569d4-1761-4a99-8bbc-7f40aa243fce" }.to_json,
        territory_code:      "123456789",
        name:                "CA du Pays Basque",
        siren:               "123456789",
        contact_first_name:  "Christelle",
        contact_last_name:   "Droitier",
        contact_email:       "christelle.droitier@pays-basque.fr",
        contact_phone:       "+0000",
        allow_2fa_via_email: "true",
        domain_restriction:  "@pays-basque.fr",
        something_else:      "true"
      }
    end

    it_behaves_like "when current user is a publisher super admin" do
      it do
        is_expected.to include(
          territory_type:      attributes[:territory_type],
          territory_id:        attributes[:territory_id],
          territory_data:      attributes[:territory_data],
          territory_code:      attributes[:territory_code],
          name:                attributes[:name],
          siren:               attributes[:siren],
          contact_first_name:  attributes[:contact_first_name],
          contact_last_name:   attributes[:contact_last_name],
          contact_email:       attributes[:contact_email],
          contact_phone:       attributes[:contact_phone],
          allow_2fa_via_email: attributes[:allow_2fa_via_email]
        ).and not_include(
          :publisher_id,
          :domain_restriction,
          :something_else
        )
      end
    end

    it_behaves_like "when current user is a publisher admin" do
      it do
        is_expected.to include(
          territory_type:      attributes[:territory_type],
          territory_id:        attributes[:territory_id],
          territory_data:      attributes[:territory_data],
          territory_code:      attributes[:territory_code],
          name:                attributes[:name],
          siren:               attributes[:siren],
          contact_first_name:  attributes[:contact_first_name],
          contact_last_name:   attributes[:contact_last_name],
          contact_email:       attributes[:contact_email],
          contact_phone:       attributes[:contact_phone],
          allow_2fa_via_email: attributes[:allow_2fa_via_email]
        ).and not_include(
          :publisher_id,
          :domain_restriction,
          :something_else
        )
      end
    end

    it_behaves_like "when current user is a publisher user" do
      it do
        is_expected.to include(
          territory_type:      attributes[:territory_type],
          territory_id:        attributes[:territory_id],
          territory_data:      attributes[:territory_data],
          territory_code:      attributes[:territory_code],
          name:                attributes[:name],
          siren:               attributes[:siren],
          contact_first_name:  attributes[:contact_first_name],
          contact_last_name:   attributes[:contact_last_name],
          contact_email:       attributes[:contact_email],
          contact_phone:       attributes[:contact_phone],
          allow_2fa_via_email: attributes[:allow_2fa_via_email]
        ).and not_include(
          :publisher_id,
          :domain_restriction,
          :something_else
        )
      end
    end

    it_behaves_like("when current user is a DDFIP super admin")        { it { is_expected.to be_nil } }
    it_behaves_like("when current user is a DDFIP admin")              { it { is_expected.to be_nil } }
    it_behaves_like("when current user is a DDFIP user")               { it { is_expected.to be_nil } }
    it_behaves_like("when current user is a collectivity super admin") { it { is_expected.to be_nil } }
    it_behaves_like("when current user is a collectivity admin")       { it { is_expected.to be_nil } }
    it_behaves_like("when current user is a collectivity user")        { it { is_expected.to be_nil } }
  end
end
