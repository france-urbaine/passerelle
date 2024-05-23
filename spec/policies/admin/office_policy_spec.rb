# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::OfficePolicy, type: :policy do
  describe_rule :manage? do
    context "without record" do
      let(:record) { Office }

      it_behaves_like("when current user is a super admin")        { succeed }
      it_behaves_like("when current user is a DDFIP admin")        { failed }
      it_behaves_like("when current user is a DDFIP user")         { failed }
      it_behaves_like("when current user is a publisher admin")    { failed }
      it_behaves_like("when current user is a publisher user")     { failed }
      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
    end

    context "with record" do
      let(:record) { build_stubbed(:office) }

      it_behaves_like("when current user is a super admin")        { succeed }
      it_behaves_like("when current user is a DDFIP admin")        { failed }
      it_behaves_like("when current user is a DDFIP user")         { failed }
      it_behaves_like("when current user is a publisher admin")    { failed }
      it_behaves_like("when current user is a publisher user")     { failed }
      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
    end

    context "when record is owned by the current DDFIP" do
      let(:record) { build_stubbed(:office, ddfip: current_organization) }

      it_behaves_like("when current user is a DDFIP admin") { failed }
      it_behaves_like("when current user is a DDFIP user")  { failed }
    end

    context "when current user is member of the record" do
      let(:record) { build_stubbed(:office, ddfip: current_organization, users: [current_user]) }

      it_behaves_like("when current user is a DDFIP admin") { failed }
      it_behaves_like("when current user is a DDFIP user")  { failed }
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
    subject(:scope) { apply_relation_scope(Office.all) }

    it_behaves_like "when current user is a super admin" do
      it "scopes all kept offices" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "offices".*
          FROM   "offices"
          WHERE  "offices"."discarded_at" IS NULL
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
    subject(:scope) { apply_relation_scope(Office.all, name: :destroyable) }

    it_behaves_like "when current user is a super admin" do
      it "scopes all kept offices" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "offices".*
          FROM   "offices"
          WHERE  "offices"."discarded_at" IS NULL
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
    subject(:scope) { apply_relation_scope(Office.all, name: :undiscardable) }

    it_behaves_like "when current user is a super admin" do
      it "scopes all discarded offices" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "offices".*
          FROM   "offices"
          WHERE  "offices"."discarded_at" IS NOT NULL
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
        ddfip_name:     "DDFIP des Pays de la Loire",
        ddfip_id:       "f4e6854a-00fb-48c4-b669-5f0623e07778",
        name:           "PELP de Nantes",
        competences:    %w[evaluation_local_professionnel],
        users_count:    200,
        something_else: "true"
      }
    end

    it_behaves_like "when current user is a super admin" do
      it do
        is_expected.to include(
          ddfip_name:         attributes[:ddfip_name],
          ddfip_id:           attributes[:ddfip_id],
          name:               attributes[:name],
          competences:        attributes[:competences]
        ).and not_include(
          :users_count,
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
