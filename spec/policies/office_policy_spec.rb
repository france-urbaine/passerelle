# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfficePolicy do
  describe_rule :index? do
    it_behaves_like("when current user is a super admin")        { succeed }
    it_behaves_like("when current user is a DDFIP admin")        { succeed }
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

  describe_rule :manage? do
    context "without record" do
      let(:record) { Office }

      it_behaves_like("when current user is a super admin")        { succeed }
      it_behaves_like("when current user is a DDFIP admin")        { succeed }
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

      it_behaves_like("when current user is a DDFIP admin") { succeed }
      it_behaves_like("when current user is a DDFIP user")  { failed }
    end
  end

  it { expect(:edit?).to      be_an_alias_of(policy, :manage?) }
  it { expect(:update?).to    be_an_alias_of(policy, :manage?) }
  it { expect(:remove?).to    be_an_alias_of(policy, :manage?) }
  it { expect(:destroy?).to   be_an_alias_of(policy, :manage?) }
  it { expect(:undiscard?).to be_an_alias_of(policy, :manage?) }

  describe_rule :assign_ddfip? do
    it_behaves_like("when current user is a super admin")        { succeed }
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

    it_behaves_like "when current user is a DDFIP admin" do
      it "scopes all kept offices belonging to publisher" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "offices".*
          FROM   "offices"
          WHERE  "offices"."discarded_at" IS NULL
            AND  "offices"."ddfip_id" = '#{current_organization.id}'
        SQL
      end
    end

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

    it_behaves_like "when current user is a DDFIP admin" do
      it "scopes all kept offices belonging to publisher" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "offices".*
          FROM   "offices"
          WHERE  "offices"."discarded_at" IS NULL
            AND  "offices"."ddfip_id" = '#{current_organization.id}'
        SQL
      end
    end

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

    it_behaves_like "when current user is a DDFIP admin" do
      it "scopes all discarded offices belonging to publisher" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "offices".*
          FROM   "offices"
          WHERE  "offices"."ddfip_id" = '#{current_organization.id}'
            AND  "offices"."discarded_at" IS NOT NULL
        SQL
      end
    end

    it_behaves_like("when current user is a DDFIP user")         { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a publisher admin")    { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a publisher user")     { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a collectivity admin") { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a collectivity user")  { it { is_expected.to be_a_null_relation } }
  end

  describe "params scope" do
    subject(:params) do
      policy.apply_scope(target, type: :action_controller_params)&.to_hash&.symbolize_keys
    end

    let(:target) { ActionController::Parameters.new(attributes) }

    let(:attributes) do
      {
        ddfip_name:     "DDFIP des Pays de la Loire",
        ddfip_id:       "f4e6854a-00fb-48c4-b669-5f0623e07778",
        name:           "PELP de Nantes",
        action:         "evaluation_pro",
        users_count:    200,
        something_else: "true"
      }
    end

    it_behaves_like "when current user is a super admin" do
      it do
        is_expected
          .to  include(ddfip_name:         attributes[:ddfip_name])
          .and include(ddfip_id:           attributes[:ddfip_id])
          .and include(name:               attributes[:name])
          .and include(action:             attributes[:action])
          .and not_include(users_count:    attributes[:users_count])
          .and not_include(something_else: attributes[:something_else])
      end
    end

    it_behaves_like "when current user is a DDFIP admin" do
      it do
        is_expected
          .to  include(name:               attributes[:name])
          .and include(action:             attributes[:action])
          .and not_include(ddfip_name:         attributes[:ddfip_name])
          .and not_include(ddfip_id:           attributes[:ddfip_id])
          .and not_include(users_count:    attributes[:users_count])
          .and not_include(something_else: attributes[:something_else])
      end
    end

    it_behaves_like("when current user is a DDFIP user")         { it { is_expected.to be_nil } }
    it_behaves_like("when current user is a publisher admin")    { it { is_expected.to be_nil } }
    it_behaves_like("when current user is a publisher user")     { it { is_expected.to be_nil } }
    it_behaves_like("when current user is a collectivity admin") { it { is_expected.to be_nil } }
    it_behaves_like("when current user is a collectivity user")  { it { is_expected.to be_nil } }
  end
end
