# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfficePolicy do
  describe_rule :manage_collection? do
    it_behaves_like("when current user is a super admin")        { succeed }
    it_behaves_like("when current user is a DDFIP admin")        { succeed }
    it_behaves_like("when current user is a publisher admin")    { failed }
    it_behaves_like("when current user is a collectivity admin") { failed }
    it_behaves_like("when current user is a DDFIP user")         { failed }
    it_behaves_like("when current user is a publisher user")     { failed }
    it_behaves_like("when current user is a collectivity user")  { failed }
  end

  it { expect(:index?).to be_an_alias_of(policy, :manage_collection?) }
  it { expect(:create?).to be_an_alias_of(policy, :manage_collection?) }
  it { expect(:remove_all?).to be_an_alias_of(policy, :manage_collection?) }
  it { expect(:destroy_all?).to be_an_alias_of(policy, :manage_collection?) }
  it { expect(:undiscard_all?).to be_an_alias_of(policy, :manage_collection?) }

  describe_rule :manage? do
    context "without record" do
      let(:record) { Office }

      it_behaves_like("when current user is a super admin")        { succeed }
      it_behaves_like("when current user is a DDFIP admin")        { succeed }
      it_behaves_like("when current user is a publisher admin")    { failed }
      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a DDFIP user")         { failed }
      it_behaves_like("when current user is a publisher user")     { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
    end

    context "with record" do
      let(:record) { build_stubbed(:office) }

      it_behaves_like("when current user is a super admin")        { succeed }
      it_behaves_like("when current user is a DDFIP admin")        { failed }
      it_behaves_like("when current user is a publisher admin")    { failed }
      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a DDFIP user")         { failed }
      it_behaves_like("when current user is a publisher user")     { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
    end

    context "when record is owned by the current DDFIP" do
      let(:record) { build_stubbed(:office, ddfip: current_organization) }

      it_behaves_like("when current user is a DDFIP admin") { succeed }
      it_behaves_like("when current user is a DDFIP user")  { failed }
    end
  end

  it { expect(:edit?).to be_an_alias_of(policy, :manage?) }
  it { expect(:update?).to be_an_alias_of(policy, :manage?) }
  it { expect(:remove?).to be_an_alias_of(policy, :manage?) }
  it { expect(:destroy?).to be_an_alias_of(policy, :manage?) }
  it { expect(:undiscard?).to be_an_alias_of(policy, :manage?) }

  describe "relation scope", stub_factories: false do
    # The following tests will assert a list of attributes rather than of a list
    # of records to produce lighter and readable output.
    subject do
      policy.apply_scope(target, type: :active_record_relation).pluck(:name)
    end

    # The scope is ordered to have a deterministic order
    #
    let(:target) { Office.order(:name) }

    before do
      create(:office, name: "A")
      create(:office, name: "B")
      create(:office, name: "C", ddfip: current_organization) if current_organization.is_a?(DDFIP)
    end

    it_behaves_like("when current user is a super admin") do
      # Create a DDFIP super admin to ensure the current DDFIP offices are included
      let(:current_user) { create(:user, :super_admin, :ddfip) }

      it { is_expected.to eq(%w[A B C]) }
    end

    it_behaves_like("when current user is a DDFIP admin")        { it { is_expected.to eq(%w[C]) } }
    it_behaves_like("when current user is a publisher admin")    { it { is_expected.to be_empty } }
    it_behaves_like("when current user is a collectivity admin") { it { is_expected.to be_empty } }
    it_behaves_like("when current user is a DDFIP user")         { it { is_expected.to be_empty } }
    it_behaves_like("when current user is a publisher user")     { it { is_expected.to be_empty } }
    it_behaves_like("when current user is a collectivity user")  { it { is_expected.to be_empty } }
  end

  describe "params scope" do
    # It's easier to assert the hash representation, not the ActionController::Params object
    #
    subject do
      policy.apply_scope(target, type: :action_controller_params).to_hash.symbolize_keys
    end

    let(:target) { ActionController::Parameters.new(attributes) }
    let(:attributes) do
      {
        ddfip_name:   "DDFIP des Pays de la Loire",
        ddfip_id:     "f4e6854a-00fb-48c4-b669-5f0623e07778",
        name:         "PELP de Nantes",
        action:       "evaluation_eco"
      }
    end

    it_behaves_like("when current user is a super admin") do
      it { is_expected.to eq(attributes) }
    end

    it_behaves_like("when current user is a DDFIP admin") do
      it do
        is_expected.to eq(
          name:   "PELP de Nantes",
          action: "evaluation_eco"
        )
      end
    end
  end
end
