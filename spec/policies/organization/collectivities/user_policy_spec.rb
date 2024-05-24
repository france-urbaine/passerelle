# frozen_string_literal: true

require "rails_helper"

RSpec.describe Organization::Collectivities::UserPolicy, type: :policy do
  let(:collectivity) { build_stubbed(:collectivity) }
  let(:context)      { { user: current_user, collectivity: collectivity } }

  shared_context "when the collectivity allowed to be managed by its publisher" do
    let(:collectivity) { build_stubbed(:collectivity, allow_publisher_management: true) }
  end

  shared_context "when the collectivity disallowed to be managed by the current publisher" do
    let(:collectivity) { build_stubbed(:collectivity, publisher: current_organization) }
  end

  shared_context "when the collectivity allowed to be managed by the current publisher" do
    let(:collectivity) { build_stubbed(:collectivity, publisher: current_organization, allow_publisher_management: true) }
  end

  describe_rule :manage? do
    context "without record" do
      let(:record) { User }

      context "without collectivity in context" do
        let(:context) { super().without(:collectivity) }

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

      context "when the collectivity disallowed to be managed by its publisher" do
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

      it_behaves_like "when the collectivity allowed to be managed by its publisher" do
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

      it_behaves_like "when the collectivity allowed to be managed by the current publisher" do
        it_behaves_like("when current user is a publisher super admin") { succeed }
        it_behaves_like("when current user is a publisher admin")       { succeed }
        it_behaves_like("when current user is a publisher user")        { succeed }
      end
    end

    context "with an user" do
      let(:record) { build_stubbed(:user) }

      context "when the collectivity disallowed to be managed by its publisher" do
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

      it_behaves_like "when the collectivity allowed to be managed by the current publisher" do
        it_behaves_like("when current user is a publisher super admin") { failed }
        it_behaves_like("when current user is a publisher admin")       { failed }
        it_behaves_like("when current user is a publisher user")        { failed }
      end
    end

    context "with a user of the current organization" do
      let(:record) { build_stubbed(:user, organization: current_organization) }

      context "when the collectivity disallowed to be managed by its publisher" do
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

      it_behaves_like "when the collectivity allowed to be managed by the current publisher" do
        it_behaves_like("when current user is a publisher super admin") { failed }
        it_behaves_like("when current user is a publisher admin")       { failed }
        it_behaves_like("when current user is a publisher user")        { failed }
      end
    end

    context "with a user of a collectivity owned by the current organization" do
      let(:record) { build_stubbed(:user, organization: collectivity) }

      it_behaves_like "when the collectivity disallowed to be managed by the current publisher" do
        it_behaves_like("when current user is a publisher super admin") { failed }
        it_behaves_like("when current user is a publisher admin")       { failed }
        it_behaves_like("when current user is a publisher user")        { failed }
      end

      it_behaves_like "when the collectivity allowed to be managed by the current publisher" do
        it_behaves_like("when current user is a publisher super admin") { succeed }
        it_behaves_like("when current user is a publisher admin")       { succeed }
        it_behaves_like("when current user is a publisher user")        { succeed }
      end
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

    it_behaves_like "when the collectivity disallowed to be managed by the current publisher" do
      it_behaves_like("when current user is a publisher admin")       { it { is_expected.to be_a_null_relation } }
      it_behaves_like("when current user is a publisher user")        { it { is_expected.to be_a_null_relation } }
    end

    it_behaves_like "when the collectivity allowed to be managed by the current publisher" do
      it_behaves_like "when current user is a publisher user" do
        it "scopes all kept users from its own organization" do
          expect {
            scope.load
          }.to perform_sql_query(<<~SQL)
            SELECT "users".*
            FROM   "users"
            WHERE  "users"."discarded_at" IS NULL
              AND  "users"."organization_type" = 'Collectivity'
              AND  "users"."organization_id" = '#{collectivity.id}'
          SQL
        end
      end

      it_behaves_like "when current user is a publisher admin" do
        it "scopes all kept users from its own organization" do
          expect {
            scope.load
          }.to perform_sql_query(<<~SQL)
            SELECT "users".*
            FROM   "users"
            WHERE  "users"."discarded_at" IS NULL
              AND  "users"."organization_type" = 'Collectivity'
              AND  "users"."organization_id" = '#{collectivity.id}'
          SQL
        end
      end
    end

    it_behaves_like("when current user is a DDFIP super admin")        { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a DDFIP admin")              { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a DDFIP user")               { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a collectivity super admin") { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a collectivity admin")       { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a collectivity user")        { it { is_expected.to be_a_null_relation } }
  end

  describe "destroyable relation scope" do
    subject(:scope) { apply_relation_scope(User.all, name: :destroyable) }

    it_behaves_like "when the collectivity disallowed to be managed by the current publisher" do
      it_behaves_like("when current user is a publisher admin")       { it { is_expected.to be_a_null_relation } }
      it_behaves_like("when current user is a publisher user")        { it { is_expected.to be_a_null_relation } }
    end

    it_behaves_like "when the collectivity allowed to be managed by the current publisher" do
      it_behaves_like "when current user is a publisher user" do
        it "scopes all kept users from its own organization" do
          expect {
            scope.load
          }.to perform_sql_query(<<~SQL)
            SELECT "users".*
            FROM   "users"
            WHERE  "users"."discarded_at" IS NULL
              AND  "users"."organization_type" = 'Collectivity'
              AND  "users"."organization_id" = '#{collectivity.id}'
              AND "users"."id" != '#{current_user.id}'
          SQL
        end
      end

      it_behaves_like "when current user is a publisher admin" do
        it "scopes all kept users from its own organization" do
          expect {
            scope.load
          }.to perform_sql_query(<<~SQL)
            SELECT "users".*
            FROM   "users"
            WHERE  "users"."discarded_at" IS NULL
              AND  "users"."organization_type" = 'Collectivity'
              AND  "users"."organization_id" = '#{collectivity.id}'
              AND "users"."id" != '#{current_user.id}'
          SQL
        end
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
    subject(:scope) { apply_relation_scope(User.all, name: :undiscardable) }

    it_behaves_like "when the collectivity disallowed to be managed by the current publisher" do
      it_behaves_like("when current user is a publisher admin")       { it { is_expected.to be_a_null_relation } }
      it_behaves_like("when current user is a publisher user")        { it { is_expected.to be_a_null_relation } }
    end

    it_behaves_like "when the collectivity allowed to be managed by the current publisher" do
      it_behaves_like "when current user is a publisher user" do
        it "scopes all kept users from its own organization" do
          expect {
            scope.load
          }.to perform_sql_query(<<~SQL)
            SELECT "users".*
            FROM   "users"
            WHERE  "users"."organization_type" = 'Collectivity'
              AND  "users"."organization_id" = '#{collectivity.id}'
              AND  "users"."discarded_at" IS NOT NULL
          SQL
        end
      end

      it_behaves_like "when current user is a publisher admin" do
        it "scopes all kept users from its own organization" do
          expect {
            scope.load
          }.to perform_sql_query(<<~SQL)
            SELECT "users".*
            FROM   "users"
            WHERE  "users"."organization_type" = 'Collectivity'
              AND  "users"."organization_id" = '#{collectivity.id}'
              AND  "users"."discarded_at" IS NOT NULL
          SQL
        end
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
        organization_type:  "DDFIP",
        organization_id:    "f4e6854a-00fb-48c4-b669-5f0623e07778",
        first_name:         "Juliette",
        last_name:          "Lemoine",
        email:              "juliette.lemoine@example.org",
        organization_admin: "false",
        super_admin:        "false",
        office_ids:         ["", "f3fabf04-eef3-4dee-989f-102b5842e18c"],
        otp_secret:         "123456789"
      }
    end

    it_behaves_like "when current user is a publisher user" do
      it do
        is_expected.to include(
          first_name:         attributes[:first_name],
          last_name:          attributes[:last_name],
          email:              attributes[:email]
        ).and not_include(
          :organization_type,
          :organization_id,
          :organization_admin,
          :super_admin,
          :office_ids,
          :otp_secret
        )
      end
    end

    it_behaves_like "when current user is a publisher admin" do
      it do
        is_expected.to include(
          first_name:         attributes[:first_name],
          last_name:          attributes[:last_name],
          email:              attributes[:email],
          organization_admin: attributes[:organization_admin]
        ).and not_include(
          :organization_type,
          :organization_id,
          :super_admin,
          :office_ids,
          :otp_secret
        )
      end

      it "allows super_admin when it's also a super admin" do
        current_user.super_admin = true

        is_expected.to include(
          first_name:         attributes[:first_name],
          last_name:          attributes[:last_name],
          email:              attributes[:email],
          organization_admin: attributes[:organization_admin],
          super_admin:        attributes[:super_admin]
        ).and not_include(
          :organization_type,
          :organization_id,
          :office_ids,
          :otp_secret
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
