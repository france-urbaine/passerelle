# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::DGFIPPolicy do
  describe_rule :manage? do
    context "without record" do
      let(:record) { DGFIP }

      it_behaves_like("when current user is a super admin")        { succeed }
      it_behaves_like("when current user is a DDFIP admin")        { failed }
      it_behaves_like("when current user is a DDFIP user")         { failed }
      it_behaves_like("when current user is a DGFIP admin")        { failed }
      it_behaves_like("when current user is a DGFIP user")         { failed }
      it_behaves_like("when current user is a publisher admin")    { failed }
      it_behaves_like("when current user is a publisher user")     { failed }
      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
    end

    context "with a DGFIP" do
      let(:record) { build_stubbed(:dgfip) }

      it_behaves_like("when current user is a super admin")        { succeed }
      it_behaves_like("when current user is a DDFIP admin")        { failed }
      it_behaves_like("when current user is a DDFIP user")         { failed }
      it_behaves_like("when current user is a DGFIP admin")        { failed }
      it_behaves_like("when current user is a DGFIP user")         { failed }
      it_behaves_like("when current user is a publisher admin")    { failed }
      it_behaves_like("when current user is a publisher user")     { failed }
      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
    end

    context "with the same DGFIP as the current organization" do
      let(:record) { current_organization }

      it_behaves_like("when current user is a DGFIP super admin") { succeed }
      it_behaves_like("when current user is a DGFIP admin")       { failed }
      it_behaves_like("when current user is a DGFIP user")        { failed }
    end
  end

  it { expect(:index?).to         be_an_alias_of(policy, :manage?) }
  it { expect(:show?).to          be_an_alias_of(policy, :manage?) }
  it { expect(:new?).to           be_an_alias_of(policy, :manage?) }
  it { expect(:create?).to        be_an_alias_of(policy, :manage?) }
  it { expect(:edit?).to          be_an_alias_of(policy, :manage?) }
  it { expect(:update?).to        be_an_alias_of(policy, :manage?) }

  describe "default relation scope" do
    subject!(:scope) { apply_relation_scope(target) }

    let(:target) { DGFIP.all }

    it_behaves_like "when current user is a super admin" do
      it "scopes on kept DGFIPs" do
        expect {
          scope.load
        }.to perform_sql_query(<<~SQL)
          SELECT "dgfips".*
          FROM   "dgfips"
          WHERE  "dgfips"."discarded_at" IS NULL
        SQL
      end
    end

    it_behaves_like("when current user is a DGFIP admin")        { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a DGFIP user")         { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a publisher admin")    { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a publisher user")     { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a collectivity admin") { it { is_expected.to be_a_null_relation } }
    it_behaves_like("when current user is a collectivity user")  { it { is_expected.to be_a_null_relation } }
  end

  describe "params scope" do
    subject(:params) { apply_params_scope(attributes) }

    let(:attributes) do
      {
        name:                "DGFIP tets",
        contact_first_name:  "Jean",
        contact_last_name:   "Valjean",
        contact_email:       "jean.valjean@dgfip.gouv.fr",
        contact_phone:       "+0000",
        allow_2fa_via_email: "true",
        domain_restriction:  "@dgfip.gouv.fr",
        something_else:      "true"
      }
    end

    it_behaves_like "when current user is a super admin" do
      it do
        is_expected
          .to  include(name:                attributes[:name])
          .and include(contact_first_name:  attributes[:contact_first_name])
          .and include(contact_last_name:   attributes[:contact_last_name])
          .and include(contact_email:       attributes[:contact_email])
          .and include(contact_phone:       attributes[:contact_phone])
          .and include(allow_2fa_via_email: attributes[:allow_2fa_via_email])
          .and not_include(:domain_restriction)
          .and not_include(:something_else)
      end
    end

    it_behaves_like("when current user is a DGFIP admin")        { it { is_expected.to be_nil } }
    it_behaves_like("when current user is a DGFIP user")         { it { is_expected.to be_nil } }
    it_behaves_like("when current user is a publisher admin")    { it { is_expected.to be_nil } }
    it_behaves_like("when current user is a publisher user")     { it { is_expected.to be_nil } }
    it_behaves_like("when current user is a collectivity admin") { it { is_expected.to be_nil } }
    it_behaves_like("when current user is a collectivity user")  { it { is_expected.to be_nil } }
  end
end
