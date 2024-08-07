# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::UserPolicy, type: :policy do
  describe_rule :manage? do
    context "without record" do
      let(:record) { User }

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

    context "with a member of the current organization" do
      let(:record) { build_stubbed(:user, organization: current_organization) }

      it_behaves_like("when current user is a super admin")        { succeed }
      it_behaves_like("when current user is a DDFIP admin")        { failed }
      it_behaves_like("when current user is a DDFIP user")         { failed }
      it_behaves_like("when current user is a publisher admin")    { failed }
      it_behaves_like("when current user is a publisher user")     { failed }
      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
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
    subject(:scope) { apply_relation_scope(User.all) }

    it_behaves_like "when current user is a super admin" do
      it "scopes all kept users" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "users".*
          FROM   "users"
          WHERE  "users"."discarded_at" IS NULL
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
    subject(:scope) { apply_relation_scope(User.all, name: :destroyable) }

    it_behaves_like "when current user is a super admin" do
      it "scopes all kept users excluding himself" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "users".*
          FROM   "users"
          WHERE  "users"."discarded_at" IS NULL
            AND  "users"."id" != '#{current_user.id}'
        SQL
      end

      it "allows to explicitely include himself", scope_options: { exclude_current: false } do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "users".*
          FROM   "users"
          WHERE  "users"."discarded_at" IS NULL
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
    subject(:scope) { apply_relation_scope(User.all, name: :undiscardable) }

    it_behaves_like "when current user is a super admin" do
      it "scopes all discarded users" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "users".*
          FROM   "users"
          WHERE  "users"."discarded_at" IS NOT NULL
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
        organization_type:  "DDFIP",
        organization_id:    "f4e6854a-00fb-48c4-b669-5f0623e07778",
        organization_data:  { type: "DDFIP", id: "f4e6854a-00fb-48c4-b669-5f0623e07778" }.to_json,
        organization_name:  "DDFIP des Pays de la Loire",
        first_name:         "Juliette",
        last_name:          "Lemoine",
        email:              "juliette.lemoine@example.org",
        organization_admin: "false",
        super_admin:        "false",
        office_ids:         %w[f3fabf04-eef3-4dee-989f-102b5842e18c],
        otp_secret:         "123456789"
      }
    end

    it_behaves_like "when current user is a super admin" do
      it do
        is_expected.to include(
          organization_type:  attributes[:organization_type],
          organization_id:    attributes[:organization_id],
          organization_data:  attributes[:organization_data],
          organization_name:  attributes[:organization_name],
          first_name:         attributes[:first_name],
          last_name:          attributes[:last_name],
          email:              attributes[:email],
          organization_admin: attributes[:organization_admin],
          super_admin:        attributes[:super_admin],
          office_ids:         attributes[:office_ids]
        ).and not_include(
          :otp_secret
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
