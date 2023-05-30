# frozen_string_literal: true

require "rails_helper"

RSpec.describe PublisherPolicy, type: :policy do
  describe_rule :manage? do
    context "without record" do
      let(:record) { Publisher }

      it_behaves_like("when current user is a super admin")        { succeed }
      it_behaves_like("when current user is a DDFIP admin")        { failed }
      it_behaves_like("when current user is a publisher admin")    { failed }
      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a DDFIP user")         { failed }
      it_behaves_like("when current user is a publisher user")     { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
    end

    context "with record" do
      let(:record) { build_stubbed(:publisher) }

      it_behaves_like("when current user is a super admin")        { succeed }
      it_behaves_like("when current user is a DDFIP admin")        { failed }
      it_behaves_like("when current user is a publisher admin")    { failed }
      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a DDFIP user")         { failed }
      it_behaves_like("when current user is a publisher user")     { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
    end
  end

  it { expect(:index?).to be_an_alias_of(policy, :manage?) }
  it { expect(:show?).to be_an_alias_of(policy, :manage?) }
  it { expect(:edit?).to be_an_alias_of(policy, :manage?) }
  it { expect(:update?).to be_an_alias_of(policy, :manage?) }
  it { expect(:remove?).to be_an_alias_of(policy, :manage?) }
  it { expect(:destroy?).to be_an_alias_of(policy, :manage?) }
  it { expect(:undiscard?).to be_an_alias_of(policy, :manage?) }

  it { expect(:manage_collection?).to be_an_alias_of(policy, :manage?) }
  it { expect(:remove_all?).to be_an_alias_of(policy, :manage_collection?) }
  it { expect(:destroy_all?).to be_an_alias_of(policy, :manage_collection?) }
  it { expect(:undiscard_all?).to be_an_alias_of(policy, :manage_collection?) }
end
