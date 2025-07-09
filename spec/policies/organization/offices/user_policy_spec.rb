# frozen_string_literal: true

require "rails_helper"

RSpec.describe Organization::Offices::UserPolicy, type: :policy do
  describe_rule :manage? do
    context "without record" do
      let(:record) { User }

      it_behaves_like("when current user is a super admin")        { failed }
      it_behaves_like("when current user is a DDFIP admin")        { succeed }
      it_behaves_like("when current user is a DDFIP supervisor")   { succeed }
      it_behaves_like("when current user is a DDFIP user")         { failed }
      it_behaves_like("when current user is a publisher admin")    { failed }
      it_behaves_like("when current user is a publisher user")     { failed }
      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
    end

    context "with a collectivity" do
      let(:record) { build_stubbed(:user) }

      it_behaves_like("when current user is a super admin")        { failed }
      it_behaves_like("when current user is a DDFIP admin")        { failed }
      it_behaves_like("when current user is a DDFIP supervisor")   { failed }
      it_behaves_like("when current user is a DDFIP user")         { failed }
      it_behaves_like("when current user is a publisher admin")    { failed }
      it_behaves_like("when current user is a publisher user")     { failed }
      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
    end

    context "with a member of the current organization" do
      let(:record) { build_stubbed(:user, organization: current_organization) }

      it_behaves_like("when current user is a super admin")        { failed }
      it_behaves_like("when current user is a DDFIP admin")        { succeed }
      it_behaves_like("when current user is a DDFIP supervisor")   { succeed }
      it_behaves_like("when current user is a DDFIP user")         { failed }
      it_behaves_like("when current user is a publisher admin")    { failed }
      it_behaves_like("when current user is a publisher user")     { failed }
      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
    end
  end

  it { expect(:index?).to         be_an_alias_of(policy, :manage?) }
  it { expect(:new?).to           be_an_alias_of(policy, :manage?) }
  it { expect(:create?).to        be_an_alias_of(policy, :manage?) }
  it { expect(:remove?).to        be_an_alias_of(policy, :manage?) }
  it { expect(:destroy?).to       be_an_alias_of(policy, :manage?) }
  it { expect(:remove_all?).to    be_an_alias_of(policy, :manage?) }
  it { expect(:destroy_all?).to   be_an_alias_of(policy, :manage?) }
  it { expect(:edit_all?).to      be_an_alias_of(policy, :manage?) }
  it { expect(:update_all?).to    be_an_alias_of(policy, :manage?) }

  it { expect(:show?).to          be_an_alias_of(policy, :not_supported?) }
  it { expect(:edit?).to          be_an_alias_of(policy, :not_supported?) }
  it { expect(:update?).to        be_an_alias_of(policy, :not_supported?) }
  it { expect(:undiscard?).to     be_an_alias_of(policy, :not_supported?) }
  it { expect(:undiscard_all?).to be_an_alias_of(policy, :not_supported?) }
end
