# frozen_string_literal: true

require "rails_helper"

RSpec.describe PublisherPolicy do
  describe_rule :manage? do
    context "without record" do
      let(:record) { Publisher }

      it_behaves_like("when current user is a super admin")        { succeed }
      it_behaves_like("when current user is a DDFIP admin")        { failed }
      it_behaves_like("when current user is a DDFIP user")         { failed }
      it_behaves_like("when current user is a publisher admin")    { failed }
      it_behaves_like("when current user is a publisher user")     { failed }
      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
    end

    context "with a publisher" do
      let(:record) { build_stubbed(:publisher) }

      it_behaves_like("when current user is a super admin")        { succeed }
      it_behaves_like("when current user is a DDFIP admin")        { failed }
      it_behaves_like("when current user is a DDFIP user")         { failed }
      it_behaves_like("when current user is a publisher admin")    { failed }
      it_behaves_like("when current user is a publisher user")     { failed }
      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
    end

    context "with the same publisher as the current organization" do
      let(:record) { current_organization }

      it_behaves_like("when current user is a super admin")     { succeed }
      it_behaves_like("when current user is a publisher admin") { failed }
      it_behaves_like("when current user is a publisher user")  { failed }
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
    subject!(:scope) do
      policy.apply_scope(target, type: :active_record_relation)
    end

    let(:target) { Publisher.all }

    it_behaves_like "when current user is a super admin" do
      it "scopes on kept publishers" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "publishers".*
          FROM   "publishers"
          WHERE  "publishers"."discarded_at" IS NULL
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
      policy.apply_scope(
        target,
        name: :destroyable,
        type: :active_record_relation,
        scope_options: scope_options
      )
    end

    let(:target)        { Publisher.all }
    let(:scope_options) { |e| e.metadata.fetch(:scope_options, {}) }

    it_behaves_like "when current user is a publisher super admin" do
      it "scopes all kept publishers" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "publishers".*
          FROM   "publishers"
          WHERE  "publishers"."discarded_at" IS NULL
            AND  "publishers"."id" != '#{current_organization.id}'
        SQL
      end

      it "allows to explicitely include its own organization", scope_options: { exclude_current: false } do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "publishers".*
          FROM   "publishers"
          WHERE  "publishers"."discarded_at" IS NULL
        SQL
      end
    end

    it_behaves_like "when current user is a DDFIP super admin" do
      it "scopes all kept publishers" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "publishers".*
          FROM   "publishers"
          WHERE  "publishers"."discarded_at" IS NULL
        SQL
      end
    end

    it_behaves_like "when current user is a collectivity super admin" do
      it "scopes all kept publishers" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "publishers".*
          FROM   "publishers"
          WHERE  "publishers"."discarded_at" IS NULL
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

    let(:target) { Publisher.all }

    it_behaves_like "when current user is a super admin" do
      it "scopes all discarded publishers" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "publishers".*
          FROM   "publishers"
          WHERE  "publishers"."discarded_at" IS NOT NULL
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
    subject(:params) do
      policy.apply_scope(target, type: :action_controller_params)&.to_hash&.symbolize_keys
    end

    let(:target) { ActionController::Parameters.new(attributes) }

    let(:attributes) do
      {
        name:                "Fiscalité & Territoire",
        siren:               "123456789",
        contact_first_name:  "Marc",
        contact_last_name:   "Debomy",
        contact_email:       "marc.debomy@fiscalite-territoire.fr",
        contact_phone:       "+0000",
        allow_2fa_via_email: "true",
        domain_restriction:  "@fiscalite-territoire.fr",
        something_else:      "true"
      }
    end

    it_behaves_like "when current user is a super admin" do
      it do
        is_expected
          .to  include(name:                attributes[:name])
          .and include(siren:               attributes[:siren])
          .and include(contact_first_name:  attributes[:contact_first_name])
          .and include(contact_last_name:   attributes[:contact_last_name])
          .and include(contact_email:       attributes[:contact_email])
          .and include(contact_phone:       attributes[:contact_phone])
          .and include(allow_2fa_via_email: attributes[:allow_2fa_via_email])
          .and not_include(:domain_restriction)
          .and not_include(:something_else)
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
