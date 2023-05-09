# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Offices nested under users" do
  it { expect(get:    "/utilisateurs/offices").to route_to("users/offices#index") }
  it { expect(post:   "/utilisateurs/offices").to be_unroutable }
  it { expect(patch:  "/utilisateurs/offices").to be_unroutable }
  it { expect(delete: "/utilisateurs/offices").to be_unroutable }

  it { expect(get:    "/utilisateurs/offices/new").to       be_unroutable }
  it { expect(get:    "/utilisateurs/offices/edit").to      be_unroutable }
  it { expect(get:    "/utilisateurs/offices/remove").to    be_unroutable }
  it { expect(get:    "/utilisateurs/offices/undiscard").to be_unroutable }

  it { expect(get:    "/utilisateurs/offices/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(post:   "/utilisateurs/offices/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(patch:  "/utilisateurs/offices/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
  it { expect(delete: "/utilisateurs/offices/b12170f4-0827-48f2-9e25-e1154c354bb6").to be_unroutable }
end
