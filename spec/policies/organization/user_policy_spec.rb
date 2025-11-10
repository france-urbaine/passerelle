# frozen_string_literal: true

require "rails_helper"

RSpec.describe Organization::UserPolicy, type: :policy do
  describe_rule :show? do
    context "without record" do
      let(:record) { User }

      it_behaves_like("when current user is a DDFIP super admin")        { failed }
      it_behaves_like("when current user is a DDFIP admin")              { succeed }
      it_behaves_like("when current user is a DDFIP supervisor")         { succeed }
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
      it_behaves_like("when current user is a DDFIP supervisor")         { failed }
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
      it_behaves_like("when current user is a DDFIP supervisor")         { failed }
      it_behaves_like("when current user is a DDFIP user")               { failed }
      it_behaves_like("when current user is a publisher super admin")    { failed }
      it_behaves_like("when current user is a publisher admin")          { succeed }
      it_behaves_like("when current user is a publisher user")           { failed }
      it_behaves_like("when current user is a collectivity super admin") { failed }
      it_behaves_like("when current user is a collectivity admin")       { succeed }
      it_behaves_like("when current user is a collectivity user")        { failed }
    end

    context "with a member of a supervised office" do
      let(:office)      { (current_user.office_users.any? && current_user.office_users.first.office) || build(:office) }
      let(:office_user) { build_stubbed(:office_user, office:) }
      let(:record)      { build_stubbed(:user, organization: current_organization, offices: [office], office_users: [office_user]) }

      it_behaves_like("when current user is a DDFIP admin")              { succeed }
      it_behaves_like("when current user is a DDFIP supervisor")         { succeed }
      it_behaves_like("when current user is a DDFIP user")               { failed }
    end

    context "with a member of a collectivity owned by the current organization" do
      let(:collectivity) { build_stubbed(:collectivity, publisher: current_organization) }
      let(:record)       { build_stubbed(:user, organization: collectivity) }

      it_behaves_like("when current user is a publisher super admin")    { failed }
      it_behaves_like("when current user is a publisher admin")          { failed }
      it_behaves_like("when current user is a publisher user")           { failed }
    end
  end

  it { expect(:index?).to be_an_alias_of(policy, :show?) }

  describe_rule :manage? do
    context "without record" do
      let(:record) { User }

      it_behaves_like("when current user is a DDFIP super admin")        { failed }
      it_behaves_like("when current user is a DDFIP admin")              { succeed }
      it_behaves_like("when current user is a DDFIP supervisor")         { succeed }
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
      it_behaves_like("when current user is a DDFIP supervisor")         { failed }
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
      it_behaves_like("when current user is a DDFIP supervisor")         { failed }
      it_behaves_like("when current user is a DDFIP user")               { failed }
      it_behaves_like("when current user is a publisher super admin")    { failed }
      it_behaves_like("when current user is a publisher admin")          { succeed }
      it_behaves_like("when current user is a publisher user")           { failed }
      it_behaves_like("when current user is a collectivity super admin") { failed }
      it_behaves_like("when current user is a collectivity admin")       { succeed }
      it_behaves_like("when current user is a collectivity user")        { failed }
    end

    context "with a super admin, member of the current organization" do
      let(:record) { build_stubbed(:user, :super_admin, organization: current_organization) }

      it_behaves_like("when current user is a DDFIP super admin")                { failed }
      it_behaves_like("when current user is a DDFIP admin & super admin")        { succeed }
      it_behaves_like("when current user is a DDFIP supervisor")                 { failed }
      it_behaves_like("when current user is a DDFIP admin")                      { failed }
      it_behaves_like("when current user is a DDFIP user")                       { failed }
      it_behaves_like("when current user is a publisher admin & super admin")    { succeed }
      it_behaves_like("when current user is a publisher super admin")            { failed }
      it_behaves_like("when current user is a publisher admin")                  { failed }
      it_behaves_like("when current user is a publisher user")                   { failed }
      it_behaves_like("when current user is a collectivity super admin")         { failed }
      it_behaves_like("when current user is a collectivity admin & super admin") { succeed }
      it_behaves_like("when current user is a collectivity admin")               { failed }
      it_behaves_like("when current user is a collectivity user")                { failed }
    end

    context "with a member of a supervised office" do
      let(:office)      { (current_user.office_users.any? && current_user.office_users.first.office) || build(:office) }
      let(:office_user) { build_stubbed(:office_user, office:) }
      let(:record)      { build_stubbed(:user, organization: current_organization, offices: [office], office_users: [office_user]) }

      it_behaves_like("when current user is a DDFIP admin")              { succeed }
      it_behaves_like("when current user is a DDFIP supervisor")         { succeed }
      it_behaves_like("when current user is a DDFIP user")               { failed }
    end

    context "with a member of a collectivity owned by the current organization" do
      let(:collectivity) { build_stubbed(:collectivity, publisher: current_organization) }
      let(:record)       { build_stubbed(:user, organization: collectivity) }

      it_behaves_like("when current user is a publisher super admin")    { failed }
      it_behaves_like("when current user is a publisher admin")          { failed }
      it_behaves_like("when current user is a publisher user")           { failed }
    end
  end

  it { expect(:new?).to           be_an_alias_of(policy, :manage?) }
  it { expect(:create?).to        be_an_alias_of(policy, :manage?) }

  describe_rule :edit? do
    context "without record" do
      let(:record) { User }

      it_behaves_like("when current user is a DDFIP super admin")        { failed }
      it_behaves_like("when current user is a DDFIP admin")              { succeed }
      it_behaves_like("when current user is a DDFIP supervisor")         { succeed }
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
      it_behaves_like("when current user is a DDFIP supervisor")         { failed }
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
      it_behaves_like("when current user is a DDFIP supervisor")         { succeed }
      it_behaves_like("when current user is a DDFIP user")               { failed }
      it_behaves_like("when current user is a publisher super admin")    { failed }
      it_behaves_like("when current user is a publisher admin")          { succeed }
      it_behaves_like("when current user is a publisher user")           { failed }
      it_behaves_like("when current user is a collectivity super admin") { failed }
      it_behaves_like("when current user is a collectivity admin")       { succeed }
      it_behaves_like("when current user is a collectivity user")        { failed }
    end

    context "with a super admin, member of the current organization" do
      let(:record) { build_stubbed(:user, :super_admin, organization: current_organization) }

      it_behaves_like("when current user is a DDFIP super admin")                { failed }
      it_behaves_like("when current user is a DDFIP admin & super admin")        { succeed }
      it_behaves_like("when current user is a DDFIP supervisor")                 { failed }
      it_behaves_like("when current user is a DDFIP admin")                      { failed }
      it_behaves_like("when current user is a DDFIP user")                       { failed }
      it_behaves_like("when current user is a publisher admin & super admin")    { succeed }
      it_behaves_like("when current user is a publisher super admin")            { failed }
      it_behaves_like("when current user is a publisher admin")                  { failed }
      it_behaves_like("when current user is a publisher user")                   { failed }
      it_behaves_like("when current user is a collectivity super admin")         { failed }
      it_behaves_like("when current user is a collectivity admin & super admin") { succeed }
      it_behaves_like("when current user is a collectivity admin")               { failed }
      it_behaves_like("when current user is a collectivity user")                { failed }
    end

    context "with a member of a supervised office" do
      let(:office)      { (current_user.office_users.any? && current_user.office_users.first.office) || build(:office) }
      let(:office_user) { build_stubbed(:office_user, office:) }
      let(:record)      { build_stubbed(:user, organization: current_organization, offices: [office], office_users: [office_user]) }

      it_behaves_like("when current user is a DDFIP admin")              { succeed }
      it_behaves_like("when current user is a DDFIP supervisor")         { succeed }
      it_behaves_like("when current user is a DDFIP user")               { failed }
    end

    context "with a member of a collectivity owned by the current organization" do
      let(:collectivity) { build_stubbed(:collectivity, publisher: current_organization) }
      let(:record)       { build_stubbed(:user, organization: collectivity) }

      it_behaves_like("when current user is a publisher super admin")    { failed }
      it_behaves_like("when current user is a publisher admin")          { failed }
      it_behaves_like("when current user is a publisher user")           { failed }
    end
  end

  it { expect(:edit?).to be_an_alias_of(policy, :update?) }

  describe_rule :destroy? do
    context "without record" do
      let(:record) { User }

      it_behaves_like("when current user is a DDFIP super admin")        { failed }
      it_behaves_like("when current user is a DDFIP admin")              { succeed }
      it_behaves_like("when current user is a DDFIP supervisor")         { failed }
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
      it_behaves_like("when current user is a DDFIP supervisor")         { failed }
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
      it_behaves_like("when current user is a DDFIP supervisor")         { failed }
      it_behaves_like("when current user is a DDFIP user")               { failed }
      it_behaves_like("when current user is a publisher super admin")    { failed }
      it_behaves_like("when current user is a publisher admin")          { succeed }
      it_behaves_like("when current user is a publisher user")           { failed }
      it_behaves_like("when current user is a collectivity super admin") { failed }
      it_behaves_like("when current user is a collectivity admin")       { succeed }
      it_behaves_like("when current user is a collectivity user")        { failed }
    end

    context "with a super admin, member of the current organization" do
      let(:record) { build_stubbed(:user, :super_admin, organization: current_organization) }

      it_behaves_like("when current user is a DDFIP super admin")                { failed }
      it_behaves_like("when current user is a DDFIP admin & super admin")        { succeed }
      it_behaves_like("when current user is a DDFIP supervisor")                 { failed }
      it_behaves_like("when current user is a DDFIP admin")                      { failed }
      it_behaves_like("when current user is a DDFIP user")                       { failed }
      it_behaves_like("when current user is a publisher admin & super admin")    { succeed }
      it_behaves_like("when current user is a publisher super admin")            { failed }
      it_behaves_like("when current user is a publisher admin")                  { failed }
      it_behaves_like("when current user is a publisher user")                   { failed }
      it_behaves_like("when current user is a collectivity super admin")         { failed }
      it_behaves_like("when current user is a collectivity admin & super admin") { succeed }
      it_behaves_like("when current user is a collectivity admin")               { failed }
      it_behaves_like("when current user is a collectivity user")                { failed }
    end

    context "with a member of a supervised office" do
      let(:office)      { (current_user.office_users.any? && current_user.office_users.first.office) || build(:office) }
      let(:office_user) { build_stubbed(:office_user, office:) }
      let(:record)      { build_stubbed(:user, organization: current_organization, offices: [office], office_users: [office_user]) }

      it_behaves_like("when current user is a DDFIP admin")              { succeed }
      it_behaves_like("when current user is a DDFIP supervisor")         { failed }
      it_behaves_like("when current user is a DDFIP user")               { failed }
    end

    context "with a member of a supervised office and an other office" do
      let(:offices) do
        [
          (current_user.office_users.any? && current_user.office_users.first.office) || build(:office),
          build_stubbed(:office)
        ]
      end
      let(:office_users) do
        [
          build_stubbed(:office_user, office: offices[0]),
          build_stubbed(:office_user, office: offices[1])
        ]
      end
      let(:record) { build_stubbed(:user, organization: current_organization, offices:, office_users:) }

      it_behaves_like("when current user is a DDFIP admin")              { succeed }
      it_behaves_like("when current user is a DDFIP supervisor")         { failed }
      it_behaves_like("when current user is a DDFIP user")               { failed }
    end

    context "with a member of a collectivity owned by the current organization" do
      let(:collectivity) { build_stubbed(:collectivity, publisher: current_organization) }
      let(:record)       { build_stubbed(:user, organization: collectivity) }

      it_behaves_like("when current user is a publisher super admin")    { failed }
      it_behaves_like("when current user is a publisher admin")          { failed }
      it_behaves_like("when current user is a publisher user")           { failed }
    end
  end

  it { expect(:remove?).to        be_an_alias_of(policy, :destroy?) }
  it { expect(:undiscard?).to     be_an_alias_of(policy, :destroy?) }
  it { expect(:remove_all?).to    be_an_alias_of(policy, :destroy?) }
  it { expect(:destroy_all?).to   be_an_alias_of(policy, :destroy?) }
  it { expect(:undiscard_all?).to be_an_alias_of(policy, :destroy?) }

  describe "default relation scope" do
    subject(:scope) { apply_relation_scope(User.all) }

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

    it_behaves_like "when current user is a DDFIP supervisor" do
      it "scopes all kept users from its own offices" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "users".*
          FROM   "users"
          WHERE  "users"."discarded_at" IS NULL
            AND  "users"."organization_type" = 'DDFIP'
            AND  "users"."organization_id" = '#{current_organization.id}'
            AND  "users"."id" IN (
              SELECT DISTINCT "users"."id"
              FROM            "users"
              INNER JOIN      "office_users"
              ON              "office_users"."user_id" = "users"."id"
              WHERE           "users"."organization_type" = 'DDFIP'
              AND             "users"."organization_id" = '#{current_organization.id}'
              AND             "office_users"."office_id" = '#{current_organization.offices[0].id}'
            )
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
    subject(:scope) { apply_relation_scope(User.all, name: :destroyable) }

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

    it_behaves_like "when current user is a DDFIP supervisor" do
      it "scopes all kept users from its own offices excluding himself and those in other offices" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "users".*
          FROM   "users"
          WHERE  "users"."discarded_at" IS NULL
            AND  "users"."organization_type" = 'DDFIP'
            AND  "users"."organization_id" = '#{current_organization.id}'
            AND  "users"."id" IN (
              SELECT DISTINCT "users"."id"
              FROM            "users"
              INNER JOIN      "office_users"
              ON              "office_users"."user_id" = "users"."id"
              WHERE           "users"."organization_type" = 'DDFIP'
              AND             "users"."organization_id" = '#{current_organization.id}'
              AND             "office_users"."office_id" = '#{current_organization.offices[0].id}'
            )
            AND  "users"."id" != '#{current_user.id}'
            AND  "users"."id" NOT IN (
              SELECT DISTINCT "users"."id"
              FROM            "users"
              INNER JOIN      "office_users"
              ON              "office_users"."user_id" = "users"."id"
              WHERE           "users"."organization_type" = 'DDFIP'
              AND             "users"."organization_id" = '#{current_organization.id}'
              AND             "office_users"."office_id" != '#{current_organization.offices[0].id}'
            )
        SQL
      end

      it "allows to explicitely include himself", scope_options: { exclude_current: false }, stub_factories: false do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "users".*
          FROM   "users"
          WHERE  "users"."discarded_at" IS NULL
            AND  "users"."organization_type" = 'DDFIP'
            AND  "users"."organization_id" = '#{current_organization.id}'
            AND  "users"."id" IN (
              SELECT DISTINCT "users"."id"
              FROM            "users"
              INNER JOIN      "office_users"
              ON              "office_users"."user_id" = "users"."id"
              WHERE           "users"."organization_type" = 'DDFIP'
              AND             "users"."organization_id" = '#{current_organization.id}'
              AND             "office_users"."office_id" = '#{current_organization.offices[0].id}'
            )
            AND  "users"."id" NOT IN (
              SELECT DISTINCT "users"."id"
              FROM            "users"
              INNER JOIN      "office_users"
              ON              "office_users"."user_id" = "users"."id"
              WHERE           "users"."organization_type" = 'DDFIP'
              AND             "users"."organization_id" = '#{current_organization.id}'
              AND             "office_users"."office_id" != '#{current_organization.offices[0].id}'
            )
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
    subject(:scope) { apply_relation_scope(User.all, name: :undiscardable) }

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
    subject(:params) { apply_params_scope(attributes) }

    let(:attributes) do
      {
        organization_type:          "DDFIP",
        organization_id:            "f4e6854a-00fb-48c4-b669-5f0623e07778",
        organization_data:          { type: "DDFIP", id: "f4e6854a-00fb-48c4-b669-5f0623e07778" }.to_json,
        organization_name:          "DDFIP des Pays de la Loire",
        first_name:                 "Juliette",
        last_name:                  "Lemoine",
        email:                      "juliette.lemoine@example.org",
        organization_admin:         "false",
        super_admin:                "false",
        form_admin:                 "false",
        office_user:                "false",
        otp_secret:                 "123456789",
        user_form_types_attributes: {
          "0" => { "_destroy" => true, "id" => "f4e6854a-00fb-48c4-b669-5f0623e07778" },
          "1" => { "_destroy" => false, "id" => nil, "form_type" => "evaluation_local_habitation" }
        },
        office_users_attributes: {
          "0" => { "_destroy" => true, "id" => "f4e6854a-00fb-48c4-b669-5f0623e07778" },
          "1" => { "_destroy" => false, "id" => nil, "supervisor" => true, "office_id" => "f4e6854a-00fb-48c4-b669-5f0623e07778" }
        }
      }
    end

    it_behaves_like "when current user is a DDFIP admin" do
      it do
        is_expected.to include(
          first_name:                 attributes[:first_name],
          last_name:                  attributes[:last_name],
          email:                      attributes[:email],
          organization_admin:         attributes[:organization_admin],
          office_user:                attributes[:office_user],
          form_admin:                 attributes[:form_admin],
          user_form_types_attributes: attributes[:user_form_types_attributes],
          office_users_attributes:    attributes[:office_users_attributes]
        ).and not_include(
          :organization_type,
          :organization_id,
          :organization_data,
          :organization_name,
          :super_admin,
          :otp_secret
        )
      end

      context "with an update scope" do
        subject(:params) { apply_params_scope(attributes, name: :update) }

        it do
          is_expected.to include(
            first_name:                 attributes[:first_name],
            last_name:                  attributes[:last_name],
            email:                      attributes[:email],
            organization_admin:         attributes[:organization_admin],
            office_user:                attributes[:office_user],
            form_admin:                 attributes[:form_admin],
            user_form_types_attributes: attributes[:user_form_types_attributes],
            office_users_attributes:    attributes[:office_users_attributes]
          ).and not_include(
            :organization_type,
            :organization_id,
            :organization_data,
            :organization_name,
            :super_admin,
            :otp_secret
          )
        end
      end

      it "allows super_admin when it's also a super admin" do
        current_user.super_admin = true

        is_expected.to include(
          first_name:                 attributes[:first_name],
          last_name:                  attributes[:last_name],
          email:                      attributes[:email],
          organization_admin:         attributes[:organization_admin],
          office_user:                attributes[:office_user],
          form_admin:                 attributes[:form_admin],
          super_admin:                attributes[:super_admin],
          user_form_types_attributes: attributes[:user_form_types_attributes],
          office_users_attributes:    attributes[:office_users_attributes]
        ).and not_include(
          :organization_type,
          :organization_id,
          :organization_data,
          :organization_name,
          :otp_secret
        )
      end
    end

    it_behaves_like "when current user is a DDFIP supervisor" do
      before do
        current_user.office_users << OfficeUser.new(office_id: "f4e6854a-00fb-48c4-b669-5f0623e07778", supervisor: true)
      end

      it do
        is_expected.to include(
          first_name:              attributes[:first_name],
          last_name:               attributes[:last_name],
          email:                   attributes[:email],
          office_user:             attributes[:office_user],
          office_users_attributes: {
            "1" => { "_destroy" => false, "id" => nil, "supervisor" => true, "office_id" => "f4e6854a-00fb-48c4-b669-5f0623e07778" }
          }
        ).and not_include(
          :otp_secret, :office_ids, :organization_type, :organization_id, :organization_data, :organization_name, :super_admin, :organization_admin, :user_form_types_attributes, :form_admin
        )
      end

      context "with an update scope" do
        subject(:params) { apply_params_scope(attributes, name: :update) }

        it do
          is_expected.to include(
            office_user:             attributes[:office_user],
            office_users_attributes: {
              "1" => { "_destroy" => false, "id" => nil, "supervisor" => true, "office_id" => "f4e6854a-00fb-48c4-b669-5f0623e07778" }
            }
          ).and not_include(
            :first_name, :last_name, :email,
            :otp_secret, :office_ids, :organization_type, :organization_id, :organization_data, :organization_name, :super_admin, :organization_admin, :user_form_types_attributes
          )
        end
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
          :form_admin,
          :user_form_types_attributes,
          :office_user,
          :office_users_attributes,
          :otp_secret
        )
      end

      context "with an update scope" do
        subject(:params) { apply_params_scope(attributes, name: :update) }

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
            :form_admin,
            :user_form_types_attributes,
            :office_user,
            :office_users_attributes,
            :otp_secret
          )
        end
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
          :form_admin,
          :user_form_types_attributes,
          :office_user,
          :office_users_attributes,
          :otp_secret
        )
      end

      context "with an update scope" do
        subject(:params) { apply_params_scope(attributes, name: :update) }

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
            :form_admin,
            :user_form_types_attributes,
            :office_user,
            :office_users_attributes,
            :otp_secret
          )
        end
      end
    end

    it_behaves_like("when current user is a DDFIP super admin")        { it { is_expected.to be_nil } }
    it_behaves_like("when current user is a DDFIP user")               { it { is_expected.to be_nil } }
    it_behaves_like("when current user is a publisher super admin")    { it { is_expected.to be_nil } }
    it_behaves_like("when current user is a publisher user")           { it { is_expected.to be_nil } }
    it_behaves_like("when current user is a collectivity super admin") { it { is_expected.to be_nil } }
    it_behaves_like("when current user is a collectivity user")        { it { is_expected.to be_nil } }

    context "with an update scope" do
      subject(:params) { apply_params_scope(attributes, name: :update) }

      it_behaves_like("when current user is a DDFIP super admin")        { it { is_expected.to be_nil } }
      it_behaves_like("when current user is a DDFIP user")               { it { is_expected.to be_nil } }
      it_behaves_like("when current user is a publisher super admin")    { it { is_expected.to be_nil } }
      it_behaves_like("when current user is a publisher user")           { it { is_expected.to be_nil } }
      it_behaves_like("when current user is a collectivity super admin") { it { is_expected.to be_nil } }
      it_behaves_like("when current user is a collectivity user")        { it { is_expected.to be_nil } }
    end
  end
end
