# frozen_string_literal: true

require "rails_helper"

RSpec.describe Users::OrganizationSettingsPolicy do
  describe_rule :manage? do
    it_behaves_like("when current user is a super admin")        { failed }
    it_behaves_like("when current user is a DDFIP admin")        { succeed }
    it_behaves_like("when current user is a publisher admin")    { succeed }
    it_behaves_like("when current user is a collectivity admin") { succeed }
    it_behaves_like("when current user is a DDFIP user")         { failed }
    it_behaves_like("when current user is a publisher user")     { failed }
    it_behaves_like("when current user is a collectivity user")  { failed }
  end

  it { expect(:show?).to be_an_alias_of(policy, :manage?) }
  it { expect(:edit?).to be_an_alias_of(policy, :manage?) }
  it { expect(:update?).to be_an_alias_of(policy, :manage?) }
end
