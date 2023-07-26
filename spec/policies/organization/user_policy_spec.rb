# frozen_string_literal: true

require "rails_helper"

RSpec.describe Organization::UserPolicy do
  describe_rule :manage? do
    context "without record" do
      let(:record) { User }

      it_behaves_like("when current user is a DDFIP super admin")        { failed }
      it_behaves_like("when current user is a DDFIP admin")              { succeed }
      it_behaves_like("when current user is a DDFIP user")               { failed }
      it_behaves_like("when current user is a publisher super admin")    { failed }
      it_behaves_like("when current user is a publisher admin")          { succeed }
      it_behaves_like("when current user is a publisher user")           { failed }
      it_behaves_like("when current user is a collectivity super admin") { failed }
      it_behaves_like("when current user is a collectivity admin")       { succeed }
      it_behaves_like("when current user is a collectivity user")        { failed }
    end

    context "with an user" do
      let(:record) { build_stubbed(:user) }

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

    context "with a member of the current organization" do
      let(:record) { build_stubbed(:user, organization: current_organization) }

      it_behaves_like("when current user is a DDFIP super admin")        { failed }
      it_behaves_like("when current user is a DDFIP admin")              { succeed }
      it_behaves_like("when current user is a DDFIP user")               { failed }
      it_behaves_like("when current user is a publisher super admin")    { failed }
      it_behaves_like("when current user is a publisher admin")          { succeed }
      it_behaves_like("when current user is a publisher user")           { failed }
      it_behaves_like("when current user is a collectivity super admin") { failed }
      it_behaves_like("when current user is a collectivity admin")       { succeed }
      it_behaves_like("when current user is a collectivity user")        { failed }
    end

    context "with a member of a collectivity owned by the current organization" do
      let(:collectivity) { build_stubbed(:collectivity, publisher: current_organization) }
      let(:record)       { build_stubbed(:user, organization: collectivity) }

      it_behaves_like("when current user is a publisher super admin")    { failed }
      it_behaves_like("when current user is a publisher admin")          { failed }
      it_behaves_like("when current user is a publisher user")           { failed }
    end
  end

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
    subject!(:scope) do
      policy.apply_scope(target, type: :active_record_relation)
    end

    let(:target) { User.all }

    it_behaves_like "when current user is a DDFIP admin" do
      it "scopes all kept users from its own organization" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "users".*
          FROM   "users"
          WHERE  "users"."discarded_at" IS NULL
            AND  "users"."organization_type" = 'DDFIP'
            AND  "users"."organization_id" = '#{current_organization.id}'
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
            AND  "users"."organization_type" = 'Publisher'
            AND  "users"."organization_id" = '#{current_organization.id}'
        SQL
      end
    end

    it_behaves_like "when current user is a collectivity admin" do
      it "scopes all kept users from its own organization" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "users".*
          FROM   "users"
          WHERE  "users"."discarded_at" IS NULL
            AND  "users"."organization_type" = 'Collectivity'
            AND  "users"."organization_id" = '#{current_organization.id}'
        SQL
      end
    end

    it_behaves_like("when current user is a DDFIP super admin")        { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a DDFIP user")               { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a publisher super admin")    { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a publisher user")           { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a collectivity super admin") { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a collectivity user")        { it { is_expected.to be_a_null_relation } }
  end

  describe "destroyable relation scope" do
    subject!(:scope) do
      policy.apply_scope(
        target,
        name: :destroyable,
        type: :active_record_relation,
        scope_options: scope_options
      )
    end

    let(:target)        { User.all }
    let(:scope_options) { |e| e.metadata.fetch(:scope_options, {}) }

    it_behaves_like "when current user is a DDFIP admin" do
      it "scopes all kept users from its own organization excluding himself" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "users".*
          FROM   "users"
          WHERE  "users"."discarded_at" IS NULL
            AND  "users"."organization_type" = 'DDFIP'
            AND  "users"."organization_id" = '#{current_organization.id}'
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
            AND  "users"."organization_type" = 'DDFIP'
            AND  "users"."organization_id" = '#{current_organization.id}'
        SQL
      end
    end

    it_behaves_like "when current user is a publisher admin" do
      it "scopes all kept users from its own organization excluding himself" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "users".*
          FROM   "users"
          WHERE  "users"."discarded_at" IS NULL
            AND  "users"."organization_type" = 'Publisher'
            AND  "users"."organization_id" = '#{current_organization.id}'
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
            AND  "users"."organization_type" = 'Publisher'
            AND  "users"."organization_id" = '#{current_organization.id}'
        SQL
      end
    end

    it_behaves_like "when current user is a collectivity admin" do
      it "scopes all kept users from its own organization excluding himself" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "users".*
          FROM   "users"
          WHERE  "users"."discarded_at" IS NULL
            AND  "users"."organization_type" = 'Collectivity'
            AND  "users"."organization_id" = '#{current_organization.id}'
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
            AND  "users"."organization_type" = 'Collectivity'
            AND  "users"."organization_id" = '#{current_organization.id}'
        SQL
      end
    end

    it_behaves_like("when current user is a DDFIP super admin")        { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a DDFIP user")               { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a publisher super admin")    { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a publisher user")           { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a collectivity super admin") { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a collectivity user")        { it { is_expected.to be_a_null_relation } }
  end

  describe "undiscardable relation scope" do
    subject!(:scope) do
      policy.apply_scope(target, name: :undiscardable, type: :active_record_relation)
    end

    let(:target) { User.all }

    it_behaves_like "when current user is a publisher admin" do
      it "scopes all kept users from its own organization" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "users".*
          FROM   "users"
          WHERE  "users"."organization_type" = 'Publisher'
            AND  "users"."organization_id" = '#{current_organization.id}'
            AND  "users"."discarded_at" IS NOT NULL
        SQL
      end
    end

    it_behaves_like "when current user is a collectivity admin" do
      it "scopes all kept users from its own organization" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "users".*
          FROM   "users"
          WHERE  "users"."organization_type" = 'Collectivity'
            AND  "users"."organization_id" = '#{current_organization.id}'
            AND  "users"."discarded_at" IS NOT NULL
        SQL
      end
    end

    it_behaves_like "when current user is a DDFIP admin" do
      it "scopes all kept users from its own organization" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "users".*
          FROM   "users"
          WHERE  "users"."organization_type" = 'DDFIP'
            AND  "users"."organization_id" = '#{current_organization.id}'
            AND  "users"."discarded_at" IS NOT NULL
        SQL
      end
    end

    it_behaves_like("when current user is a DDFIP super admin")        { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a DDFIP user")               { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a publisher super admin")    { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a publisher user")           { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a collectivity super admin") { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a collectivity user")        { it { is_expected.to be_a_null_relation } }
  end

  describe "params scope" do
    subject(:params) do
      policy.apply_scope(target, type: :action_controller_params)&.to_hash&.symbolize_keys
    end

    let(:target) { ActionController::Parameters.new(attributes) }

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
        office_ids:         ["", "f3fabf04-eef3-4dee-989f-102b5842e18c"],
        otp_secret:         "123456789"
      }
    end

    it_behaves_like "when current user is a DDFIP admin" do
      it do
        is_expected.to include(
          first_name:         attributes[:first_name],
          last_name:          attributes[:last_name],
          email:              attributes[:email],
          organization_admin: attributes[:organization_admin],
          office_ids:         attributes[:office_ids]
        ).and not_include(
          :organization_type,
          :organization_id,
          :organization_data,
          :organization_name,
          :super_admin,
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
          super_admin:        attributes[:super_admin],
          office_ids:         attributes[:office_ids]
        ).and not_include(
          :organization_type,
          :organization_id,
          :organization_data,
          :organization_name,
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
          :organization_data,
          :organization_name,
          :super_admin,
          :office_ids,
          :otp_secret
        )
      end
    end

    it_behaves_like "when current user is a collectivity admin" do
      it do
        is_expected.to include(
          first_name:         attributes[:first_name],
          last_name:          attributes[:last_name],
          email:              attributes[:email],
          organization_admin: attributes[:organization_admin]
        ).and not_include(
          :organization_type,
          :organization_id,
          :organization_data,
          :organization_name,
          :super_admin,
          :office_ids,
          :otp_secret
        )
      end
    end

    it_behaves_like("when current user is a DDFIP super admin")        { it { is_expected.to be_nil } }
    it_behaves_like("when current user is a DDFIP user")               { it { is_expected.to be_nil } }
    it_behaves_like("when current user is a publisher super admin")    { it { is_expected.to be_nil } }
    it_behaves_like("when current user is a publisher user")           { it { is_expected.to be_nil } }
    it_behaves_like("when current user is a collectivity super admin") { it { is_expected.to be_nil } }
    it_behaves_like("when current user is a collectivity user")        { it { is_expected.to be_nil } }
  end
end
