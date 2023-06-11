# frozen_string_literal: true

require "rails_helper"

RSpec.describe Offices::UserPolicy do
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
  it { expect(:edit_all?).to      be_an_alias_of(policy, :index?) }
  it { expect(:update_all?).to    be_an_alias_of(policy, :index?) }
  it { expect(:remove_all?).to    be_an_alias_of(policy, :index?) }
  it { expect(:destroy_all?).to   be_an_alias_of(policy, :index?) }
  it { expect(:undiscard_all?).to be_an_alias_of(policy, :index?) }

  describe_rule :manage? do
    context "without record" do
      let(:record) { User }

      it_behaves_like("when current user is a super admin")        { succeed }
      it_behaves_like("when current user is a DDFIP admin")        { succeed }
      it_behaves_like("when current user is a DDFIP user")         { failed }
      it_behaves_like("when current user is a publisher admin")    { failed }
      it_behaves_like("when current user is a publisher user")     { failed }
      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
    end

    context "with user" do
      let(:record) { build_stubbed(:user) }

      it_behaves_like("when current user is a super admin")        { succeed }
      it_behaves_like("when current user is a DDFIP admin")        { failed }
      it_behaves_like("when current user is a DDFIP user")         { failed }
      it_behaves_like("when current user is a publisher admin")    { failed }
      it_behaves_like("when current user is a publisher user")     { failed }
      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
    end

    context "when member of the current DDFIP" do
      let(:record) { build_stubbed(:user, organization: current_organization) }

      it_behaves_like("when current user is a super admin")        { succeed }
      it_behaves_like("when current user is a DDFIP admin")        { succeed }
      it_behaves_like("when current user is a DDFIP user")         { failed }
      it_behaves_like("when current user is a publisher admin")    { failed }
      it_behaves_like("when current user is a publisher user")     { failed }
      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
    end
  end

  it { expect(:remove?).to  be_an_alias_of(policy, :manage?) }
  it { expect(:destroy?).to be_an_alias_of(policy, :manage?) }

  describe_rule :assign_organization? do
    it_behaves_like("when current user is a super admin")        { failed }
    it_behaves_like("when current user is a DDFIP admin")        { failed }
    it_behaves_like("when current user is a DDFIP user")         { failed }
    it_behaves_like("when current user is a publisher admin")    { failed }
    it_behaves_like("when current user is a publisher user")     { failed }
    it_behaves_like("when current user is a collectivity admin") { failed }
    it_behaves_like("when current user is a collectivity user")  { failed }
  end

  describe_rule :assign_organization_admin? do
    it_behaves_like("when current user is a super admin")        { succeed }
    it_behaves_like("when current user is a DDFIP admin")        { succeed }
    it_behaves_like("when current user is a DDFIP user")         { failed }
    it_behaves_like("when current user is a publisher admin")    { failed }
    it_behaves_like("when current user is a publisher user")     { failed }
    it_behaves_like("when current user is a collectivity admin") { failed }
    it_behaves_like("when current user is a collectivity user")  { failed }
  end

  describe_rule :assign_super_admin? do
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

    let(:target) { User.all }

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

    it_behaves_like "when current user is a DDFIP admin" do
      it "scopes all kept users from offices owned by current publisher" do
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

    it_behaves_like("when current user is a DDFIP user")          { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a publisher admin")     { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a publisher user")      { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a collectivity admin")  { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a collectivity user")   { it { is_expected.to be_a_null_relation } }
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
        office_ids:         %w[f3fabf04-eef3-4dee-989f-102b5842e18c],
        otp_secret:         "123456789"
      }
    end

    it_behaves_like "when current user is a super admin" do
      it do
        is_expected
          .to  include(first_name:         attributes[:first_name])
          .and include(last_name:          attributes[:last_name])
          .and include(email:              attributes[:email])
          .and include(organization_admin: attributes[:organization_admin])
          .and include(super_admin:        attributes[:super_admin])
          .and include(office_ids:         attributes[:office_ids])
          .and not_include(:organization_type)
          .and not_include(:organization_id)
          .and not_include(:organization_data)
          .and not_include(:organization_name)
          .and not_include(:otp_secret)
      end
    end

    it_behaves_like "when current user is a DDFIP admin" do
      it do
        is_expected
          .to  include(first_name:         attributes[:first_name])
          .and include(last_name:          attributes[:last_name])
          .and include(email:              attributes[:email])
          .and include(organization_admin: attributes[:organization_admin])
          .and include(office_ids:         attributes[:office_ids])
          .and not_include(:organization_type)
          .and not_include(:organization_id)
          .and not_include(:organization_data)
          .and not_include(:organization_name)
          .and not_include(:super_admin)
          .and not_include(:otp_secret)
      end
    end

    it_behaves_like("when current user is a DDFIP user")         { it { is_expected.to be_nil } }
    it_behaves_like("when current user is a publisher admin")    { it { is_expected.to be_nil } }
    it_behaves_like("when current user is a publisher user")     { it { is_expected.to be_nil } }
    it_behaves_like("when current user is a collectivity admin") { it { is_expected.to be_nil } }
    it_behaves_like("when current user is a collectivity user")  { it { is_expected.to be_nil } }
  end
end
