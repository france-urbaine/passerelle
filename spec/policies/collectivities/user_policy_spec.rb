# frozen_string_literal: true

require "rails_helper"

RSpec.describe Collectivities::UserPolicy, type: :policy do
  describe_rule :manage_collection? do
    it_behaves_like("when current user is a super admin")        { succeed }
    it_behaves_like("when current user is a publisher user")     { succeed }
    it_behaves_like("when current user is a publisher admin")    { succeed }
    it_behaves_like("when current user is a DDFIP admin")        { failed }
    it_behaves_like("when current user is a DDFIP user")         { failed }
    it_behaves_like("when current user is a collectivity admin") { failed }
    it_behaves_like("when current user is a collectivity user")  { failed }
  end

  it { expect(:index?).to be_an_alias_of(policy, :manage_collection?) }
  it { expect(:create?).to be_an_alias_of(policy, :manage_collection?) }
  it { expect(:remove_all?).to be_an_alias_of(policy, :manage_collection?) }
  it { expect(:destroy_all?).to be_an_alias_of(policy, :manage_collection?) }
  it { expect(:undiscard_all?).to be_an_alias_of(policy, :manage_collection?) }

  describe_rule :assign_organization? do
    it_behaves_like("when current user is a super admin")        { failed }
    it_behaves_like("when current user is a DDFIP admin")        { failed }
    it_behaves_like("when current user is a publisher admin")    { failed }
    it_behaves_like("when current user is a collectivity admin") { failed }
    it_behaves_like("when current user is a DDFIP user")         { failed }
    it_behaves_like("when current user is a publisher user")     { failed }
    it_behaves_like("when current user is a collectivity user")  { failed }
  end

  describe_rule :assign_organization_admin? do
    it_behaves_like("when current user is a super admin")        { succeed }
    it_behaves_like("when current user is a DDFIP admin")        { failed }
    it_behaves_like("when current user is a publisher admin")    { succeed }
    it_behaves_like("when current user is a collectivity admin") { failed }
    it_behaves_like("when current user is a DDFIP user")         { failed }
    it_behaves_like("when current user is a publisher user")     { failed }
    it_behaves_like("when current user is a collectivity user")  { failed }
  end

  it { expect(:assign_super_admin?).to be_an_alias_of(policy, :super_admin?) }

  describe "relation scope" do
    # The following tests will assert a list of attributes rather than of a list
    # of records to produce lighter and readable output.
    subject do
      policy.apply_scope(target, type: :active_record_relation).pluck(:first_name)
    end

    # The scope is ordered to have a deterministic order
    #
    let(:target) { User.order(:first_name) }

    before do
      [
        create(:user, :ddfip,        first_name: "A"),
        create(:user, :publisher,    first_name: "B"),
        create(:user, :collectivity, first_name: "C"),
        create(:user, organization: current_organization, first_name: "D")
      ]
    end

    it_behaves_like("when current user is a super admin")        { it { is_expected.to eq(%w[A B C D]) } }
    it_behaves_like("when current user is a DDFIP admin")        { it { is_expected.to be_empty } }
    it_behaves_like("when current user is a publisher admin")    { it { is_expected.to eq(%w[A B C D]) } }
    it_behaves_like("when current user is a collectivity admin") { it { is_expected.to be_empty } }
    it_behaves_like("when current user is a DDFIP user")         { it { is_expected.to be_empty } }
    it_behaves_like("when current user is a publisher user")     { it { is_expected.to eq(%w[A B C D]) } }
    it_behaves_like("when current user is a collectivity user")  { it { is_expected.to be_empty } }
  end
end
