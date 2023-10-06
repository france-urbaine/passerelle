# frozen_string_literal: true

require "rails_helper"

RSpec.describe Territories::UpdatesPolicy, type: :policy do
  describe_rule :update? do
    it_behaves_like("when current user is a super admin")        { succeed }
    it_behaves_like("when current user is a DDFIP admin")        { failed }
    it_behaves_like("when current user is a DDFIP user")         { failed }
    it_behaves_like("when current user is a publisher admin")    { failed }
    it_behaves_like("when current user is a publisher user")     { failed }
    it_behaves_like("when current user is a collectivity admin") { failed }
    it_behaves_like("when current user is a collectivity user")  { failed }
  end

  it { expect(:edit?).to be_an_alias_of(policy, :update?) }

  it { expect(:index?).to  be_an_alias_of(policy, :not_supported) }
  it { expect(:show?).to   be_an_alias_of(policy, :not_supported) }
  it { expect(:manage?).to be_an_alias_of(policy, :not_supported) }
end
