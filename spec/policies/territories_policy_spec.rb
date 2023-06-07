# frozen_string_literal: true

require "rails_helper"

RSpec.describe TerritoriesPolicy do
  describe_rule :index? do
    it_behaves_like("when current user is a super admin")        { succeed }
    it_behaves_like("when current user is a DDFIP admin")        { succeed }
    it_behaves_like("when current user is a publisher admin")    { succeed }
    it_behaves_like("when current user is a collectivity admin") { succeed }
    it_behaves_like("when current user is a DDFIP user")         { succeed }
    it_behaves_like("when current user is a publisher user")     { succeed }
    it_behaves_like("when current user is a collectivity user")  { succeed }
    it_behaves_like("without current user")                      { succeed }
  end

  describe_rule :manage? do
    it_behaves_like("when current user is a super admin")        { succeed }
    it_behaves_like("when current user is a DDFIP admin")        { failed }
    it_behaves_like("when current user is a publisher admin")    { failed }
    it_behaves_like("when current user is a collectivity admin") { failed }
    it_behaves_like("when current user is a DDFIP user")         { failed }
    it_behaves_like("when current user is a publisher user")     { failed }
    it_behaves_like("when current user is a collectivity user")  { failed }
    it_behaves_like("without current user")                      { failed }
  end

  it { expect(:edit?).to be_an_alias_of(policy, :manage?) }
  it { expect(:update?).to be_an_alias_of(policy, :manage?) }
end
