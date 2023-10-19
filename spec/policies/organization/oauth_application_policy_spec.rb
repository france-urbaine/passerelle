# frozen_string_literal: true

require "rails_helper"

RSpec.describe Organization::OauthApplicationPolicy, type: :policy do
  describe_rule :manage? do
    context "without record" do
      let(:record) { OauthApplication }

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

    context "with an application" do
      let(:record) { build_stubbed(:oauth_application, owner: current_organization) }

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

    context "with and application not owner by current_publisher" do
      let(:record) { build_stubbed(:oauth_application, owner: build(:publisher)) }

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
  end

  it { expect(:index?).to         be_an_alias_of(policy, :manage?) }
  it { expect(:new?).to           be_an_alias_of(policy, :manage?) }
  it { expect(:create?).to        be_an_alias_of(policy, :manage?) }
  it { expect(:show?).to          be_an_alias_of(policy, :manage?) }
  it { expect(:remove_all?).to    be_an_alias_of(policy, :manage?) }
  it { expect(:destroy_all?).to   be_an_alias_of(policy, :manage?) }
  it { expect(:undiscard_all?).to be_an_alias_of(policy, :manage?) }

  describe "default relation scope" do
    subject!(:scope) { apply_relation_scope(OauthApplication.all) }

    it_behaves_like "when current user is a publisher super admin" do
      it "scopes all kept applications owned by organization" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "oauth_applications".*
          FROM   "oauth_applications"
          WHERE  "oauth_applications"."discarded_at" IS NULL
            AND  "oauth_applications"."discarded_at" IS NULL
            AND  "oauth_applications"."owner_type" = 'Publisher'
            AND  "oauth_applications"."owner_id" = '#{current_organization.id}'
        SQL
      end
    end

    it_behaves_like "when current user is a publisher admin" do
      it "scopes all kept applications owned by organization" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "oauth_applications".*
          FROM   "oauth_applications"
          WHERE  "oauth_applications"."discarded_at" IS NULL
            AND  "oauth_applications"."discarded_at" IS NULL
            AND  "oauth_applications"."owner_type" = 'Publisher'
            AND  "oauth_applications"."owner_id" = '#{current_organization.id}'
        SQL
      end
    end

    it_behaves_like "when current user is a publisher user" do
      it "scopes all kept applications owned by organization" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "oauth_applications".*
          FROM   "oauth_applications"
          WHERE  "oauth_applications"."discarded_at" IS NULL
            AND  "oauth_applications"."discarded_at" IS NULL
            AND  "oauth_applications"."owner_type" = 'Publisher'
            AND  "oauth_applications"."owner_id" = '#{current_organization.id}'
        SQL
      end
    end

    it_behaves_like("when current user is a DDFIP admin")              { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a DDFIP super admin")        { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a DDFIP user")               { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a collectivity super admin") { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a collectivity admin")       { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a collectivity user")        { it { is_expected.to be_a_null_relation } }
  end

  describe "destroyable relation scope" do
    subject!(:scope) { apply_relation_scope(OauthApplication.all, name: :destroyable) }

    it_behaves_like "when current user is a publisher super admin" do
      it "scopes all kept applications owned by organization" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "oauth_applications".*
          FROM   "oauth_applications"
          WHERE  "oauth_applications"."discarded_at" IS NULL
            AND  "oauth_applications"."discarded_at" IS NULL
            AND  "oauth_applications"."owner_type" = 'Publisher'
            AND  "oauth_applications"."owner_id" = '#{current_organization.id}'
        SQL
      end
    end

    it_behaves_like "when current user is a publisher admin" do
      it "scopes all kept applications owned by organization" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "oauth_applications".*
          FROM   "oauth_applications"
          WHERE  "oauth_applications"."discarded_at" IS NULL
            AND  "oauth_applications"."discarded_at" IS NULL
            AND  "oauth_applications"."owner_type" = 'Publisher'
            AND  "oauth_applications"."owner_id" = '#{current_organization.id}'
        SQL
      end
    end

    it_behaves_like "when current user is a publisher user" do
      it "scopes all kept applications owned by organization" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "oauth_applications".*
          FROM   "oauth_applications"
          WHERE  "oauth_applications"."discarded_at" IS NULL
            AND  "oauth_applications"."discarded_at" IS NULL
            AND  "oauth_applications"."owner_type" = 'Publisher'
            AND  "oauth_applications"."owner_id" = '#{current_organization.id}'
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
    subject!(:scope) { apply_relation_scope(OauthApplication.all, name: :undiscardable) }

    it_behaves_like "when current user is a publisher super admin" do
      it "scopes all kept applications owned by organization" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "oauth_applications".*
          FROM   "oauth_applications"
          WHERE  "oauth_applications"."owner_type" = 'Publisher'
            AND  "oauth_applications"."owner_id" = '#{current_organization.id}'
            AND  "oauth_applications"."discarded_at" IS NOT NULL
        SQL
      end
    end

    it_behaves_like "when current user is a publisher admin" do
      it "scopes all kept applications owned by organization" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "oauth_applications".*
          FROM   "oauth_applications"
          WHERE  "oauth_applications"."owner_type" = 'Publisher'
            AND  "oauth_applications"."owner_id" = '#{current_organization.id}'
            AND  "oauth_applications"."discarded_at" IS NOT NULL
        SQL
      end
    end

    it_behaves_like "when current user is a publisher user" do
      it "scopes all kept applications owned by organization" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "oauth_applications".*
          FROM   "oauth_applications"
          WHERE  "oauth_applications"."owner_type" = 'Publisher'
            AND  "oauth_applications"."owner_id" = '#{current_organization.id}'
            AND  "oauth_applications"."discarded_at" IS NOT NULL
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

    let(:attributes) { { name: "name", sandbox: "true", not_included: "not_included" } }

    it_behaves_like "when current user is a publisher super admin" do
      it do
        is_expected.to include(
          name: "name",
          sandbox: "true"
        ).and not_include(
          :not_included
        )
      end
    end

    it_behaves_like "when current user is a publisher admin" do
      it do
        is_expected.to include(
          name: "name",
          sandbox: "true"
        ).and not_include(
          :not_included
        )
      end
    end

    it_behaves_like "when current user is a publisher user" do
      it do
        is_expected.to include(
          name: "name",
          sandbox: "true"
        ).and not_include(
          :not_included
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
