# frozen_string_literal: true

require "rails_helper"

RSpec.describe Publishers::CollectivityPolicy do
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

  describe_rule :assign_publisher? do
    context "without record" do
      let(:record) { Collectivity }

      it_behaves_like("when current user is a super admin")        { failed }
      it_behaves_like("when current user is a DDFIP admin")        { failed }
      it_behaves_like("when current user is a DDFIP user")         { failed }
      it_behaves_like("when current user is a publisher admin")    { failed }
      it_behaves_like("when current user is a publisher user")     { failed }
      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
    end
  end

  describe "default relation scope" do
    subject!(:scope) do
      policy.apply_scope(target, type: :active_record_relation)
    end

    let(:target) { Collectivity.all }

    it_behaves_like "when current user is a super admin" do
      it "scopes all kept collectivities" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "collectivities".*
          FROM   "collectivities"
          WHERE  "collectivities"."discarded_at" IS NULL
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

    it_behaves_like "when current user is a collectivity super admin" do
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

    it_behaves_like "when current user is a publisher super admin" do
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
        publisher_id:        "f4e6854a-00fb-48c4-b669-5f0623e07778",
        territory_type:      "EPCI",
        territory_id:        "738569d4-1761-4a99-8bbc-7f40aa243fce",
        territory_data:      { type: "EPCI", id: "738569d4-1761-4a99-8bbc-7f40aa243fce" }.to_json,
        territory_code:      "123456789",
        name:                "CA du Pays Basque",
        siren:               "123456789",
        contact_first_name:  "Christelle",
        contact_last_name:   "Droitier",
        contact_email:       "christelle.droitier@pays-basque.fr",
        contact_phone:       "+0000",
        allow_2fa_via_email: "true",
        domain_restriction:  "@pays-basque.fr",
        something_else:      "true"
      }
    end

    it_behaves_like "when current user is a super admin" do
      it do
        is_expected
          .to  not_include(:publisher_id)
          .and include(territory_type:      attributes[:territory_type])
          .and include(territory_id:        attributes[:territory_id])
          .and include(territory_data:      attributes[:territory_data])
          .and include(territory_code:      attributes[:territory_code])
          .and include(name:                attributes[:name])
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
