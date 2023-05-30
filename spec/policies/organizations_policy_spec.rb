# frozen_string_literal: true

require "rails_helper"

RSpec.describe OrganizationsPolicy, type: :policy do
  describe_rule :index? do
    it_behaves_like("when current user is a super admin")        { succeed }
    it_behaves_like("when current user is a DDFIP admin")        { failed }
    it_behaves_like("when current user is a publisher admin")    { failed }
    it_behaves_like("when current user is a collectivity admin") { failed }
    it_behaves_like("when current user is a DDFIP user")         { failed }
    it_behaves_like("when current user is a publisher user")     { failed }
    it_behaves_like("when current user is a collectivity user")  { failed }
  end
end
