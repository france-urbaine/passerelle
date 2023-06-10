# frozen_string_literal: true

require "rails_helper"

RSpec.describe DDFIPs::OfficePolicy do
  describe_rule :index? do
    it_behaves_like("when current user is a super admin")        { succeed }
    it_behaves_like("when current user is a DDFIP admin")        { failed }
    it_behaves_like("when current user is a DDFIP user")         { failed }
    it_behaves_like("when current user is a publisher admin")    { failed }
    it_behaves_like("when current user is a publisher user")     { failed }
    it_behaves_like("when current user is a collectivity admin") { failed }
    it_behaves_like("when current user is a collectivity user")  { failed }
  end

  it { expect(:new?).to           be_an_alias_of(policy, :index?) }
  it { expect(:create?).to        be_an_alias_of(policy, :index?) }
  it { expect(:remove_all?).to    be_an_alias_of(policy, :index?) }
  it { expect(:destroy_all?).to   be_an_alias_of(policy, :index?) }
  it { expect(:undiscard_all?).to be_an_alias_of(policy, :index?) }

  describe_rule :assign_ddfip? do
    it_behaves_like("when current user is a super admin")        { failed }
    it_behaves_like("when current user is a DDFIP admin")        { failed }
    it_behaves_like("when current user is a DDFIP user")         { failed }
    it_behaves_like("when current user is a publisher admin")    { failed }
    it_behaves_like("when current user is a publisher user")     { failed }
    it_behaves_like("when current user is a collectivity admin") { failed }
    it_behaves_like("when current user is a collectivity user")  { failed }
  end

  describe "default relation scope" do
    subject!(:scope) do
      policy.apply_scope(target, type: :active_record_relation)
    end

    let(:target) { Office.all }

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
    subject!(:scope) do
      policy.apply_scope(target, name: :destroyable, type: :active_record_relation)
    end

    let(:target) { Office.all }

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
    subject!(:scope) do
      policy.apply_scope(target, name: :undiscardable, type: :active_record_relation)
    end

    let(:target) { Office.all }

    it_behaves_like "when current user is a super admin" do
      it "scopes all kept offices" do
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
end
