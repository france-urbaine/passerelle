# frozen_string_literal: true

require "rails_helper"

RSpec.describe RegionPolicy do
  describe_rule :manage? do
    context "without record" do
      let(:record) { Region }

      it_behaves_like("when current user is a super admin")        { succeed }
      it_behaves_like("when current user is a DDFIP admin")        { failed }
      it_behaves_like("when current user is a publisher admin")    { failed }
      it_behaves_like("when current user is a collectivity admin") { failed }
      it_behaves_like("when current user is a DDFIP user")         { failed }
      it_behaves_like("when current user is a publisher user")     { failed }
      it_behaves_like("when current user is a collectivity user")  { failed }
    end

    context "with record" do
      let(:record) { build_stubbed(:region) }

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
end
