# frozen_string_literal: true

require "rails_helper"

RSpec.describe TerritoriesPolicy do
  describe_rule :index? do
    it_behaves_like("when current user is a super admin")        { succeed }
    it_behaves_like("when current user is a DDFIP admin")        { succeed }
    it_behaves_like("when current user is a DDFIP user")         { succeed }
    it_behaves_like("when current user is a publisher admin")    { succeed }
    it_behaves_like("when current user is a publisher user")     { succeed }
    it_behaves_like("when current user is a collectivity admin") { succeed }
    it_behaves_like("when current user is a collectivity user")  { succeed }
  end
end
