# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::CollectivityPolicy, type: :policy do
  describe_rule :manage? do
    context "without record" do
      let(:record) { Collectivity }

      it_behaves_like("when current user is a super admin")        { succeed }
      it_behaves_like("when current user is a DDFIP admin")        { failed }
      it_behaves_like("when current user is a DDFIP user")         { failed }
      it_behaves_like("when current user is a publisher admin")    { failed }
      it_behaves_like("when current user is a publisher user")     { failed }
      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
    end

    context "with a collectivity" do
      let(:record) { build_stubbed(:collectivity) }

      it_behaves_like("when current user is a super admin")        { succeed }
      it_behaves_like("when current user is a DDFIP admin")        { failed }
      it_behaves_like("when current user is a DDFIP user")         { failed }
      it_behaves_like("when current user is a publisher admin")    { failed }
      it_behaves_like("when current user is a publisher user")     { failed }
      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
    end

    context "with the same collectivity as the current organization" do
      let(:record) { current_organization }

      it_behaves_like("when current user is a collectivity super admin") { succeed }
      it_behaves_like("when current user is a collectivity admin")       { failed }
      it_behaves_like("when current user is a collectivity user")        { failed }
    end

    context "with a collectivity owned by the current publisher" do
      let(:record) { build_stubbed(:collectivity, publisher: current_organization) }

      it_behaves_like("when current user is a publisher super admin") { succeed }
      it_behaves_like("when current user is a publisher admin")       { failed }
      it_behaves_like("when current user is a publisher user")        { failed }
    end
  end

  it { expect(:index?).to         be_an_alias_of(policy, :manage?) }
  it { expect(:show?).to          be_an_alias_of(policy, :manage?) }
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

    it_behaves_like "when current user is a super admin" do
      it "scopes all kept collectivities" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "collectivities".*
          FROM   "collectivities"
          WHERE  "collectivities"."discarded_at" IS NULL
        SQL
      end
    end

    it_behaves_like("when current user is a DDFIP admin")        { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a DDFIP user")         { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a publisher admin")    { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a publisher user")     { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a collectivity admin") { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a collectivity user")  { it { is_expected.to be_a_null_relation } }
  end

  describe "destroyable relation scope" do
    subject(:scope) { apply_relation_scope(Collectivity.all, name: :destroyable) }

    it_behaves_like "when current user is a collectivity super admin" do
      it "scopes all kept collectivities" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "collectivities".*
          FROM   "collectivities"
          WHERE  "collectivities"."discarded_at" IS NULL
            AND  "collectivities"."id" != '#{current_organization.id}'
        SQL
      end

      it "allows to explicitely include its own organization", scope_options: { exclude_current: false } do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "collectivities".*
          FROM   "collectivities"
          WHERE  "collectivities"."discarded_at" IS NULL
        SQL
      end
    end

    it_behaves_like "when current user is a publisher super admin" do
      it "scopes all kept collectivities" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "collectivities".*
          FROM   "collectivities"
          WHERE  "collectivities"."discarded_at" IS NULL
        SQL
      end
    end

    it_behaves_like "when current user is a DDFIP super admin" do
      it "scopes all kept collectivities" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "collectivities".*
          FROM   "collectivities"
          WHERE  "collectivities"."discarded_at" IS NULL
        SQL
      end
    end

    it_behaves_like("when current user is a DDFIP admin")        { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a DDFIP user")         { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a publisher admin")    { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a publisher user")     { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a collectivity admin") { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a collectivity user")  { it { is_expected.to be_a_null_relation } }
  end

  describe "undiscardable relation scope" do
    subject(:scope) { apply_relation_scope(Collectivity.all, name: :undiscardable) }

    it_behaves_like "when current user is a super admin" do
      it "scopes all discarded collectivities" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "collectivities".*
          FROM   "collectivities"
          WHERE  "collectivities"."discarded_at" IS NOT NULL
        SQL
      end
    end

    it_behaves_like("when current user is a DDFIP admin")        { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a DDFIP user")         { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a publisher admin")    { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a publisher user")     { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a collectivity admin") { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a collectivity user")  { it { is_expected.to be_a_null_relation } }
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

    it_behaves_like "when current user is a super admin" do
      it do
        is_expected.to include(
          publisher_id:        attributes[:publisher_id],
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
          :domain_restriction,
          :something_else
        )
      end
    end

    it_behaves_like("when current user is a DDFIP admin")        { it { is_expected.to be_nil } }
    it_behaves_like("when current user is a DDFIP user")         { it { is_expected.to be_nil } }
    it_behaves_like("when current user is a publisher admin")    { it { is_expected.to be_nil } }
    it_behaves_like("when current user is a publisher user")     { it { is_expected.to be_nil } }
    it_behaves_like("when current user is a collectivity admin") { it { is_expected.to be_nil } }
    it_behaves_like("when current user is a collectivity user")  { it { is_expected.to be_nil } }
  end
end
