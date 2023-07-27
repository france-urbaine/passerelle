# frozen_string_literal: true

require "rails_helper"

RSpec.describe Territories::CommunesController do
  it { expect(get:    "/territoires/communes").to route_to("territories/communes#index") }
  it { expect(post:   "/territoires/communes").to be_unroutable }
  it { expect(patch:  "/territoires/communes").to be_unroutable }
  it { expect(delete: "/territoires/communes").to be_unroutable }

  it { expect(get:    "/territoires/communes/new").to       be_unroutable }
  it { expect(get:    "/territoires/communes/edit").to      be_unroutable }
  it { expect(get:    "/territoires/communes/remove").to    be_unroutable }
  it { expect(get:    "/territoires/communes/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/communes/undiscard").to be_unroutable }

  it { expect(get:    "/territoires/communes/9c6c00c4").to route_to("territories/communes#show", id: "9c6c00c4") }
  it { expect(post:   "/territoires/communes/9c6c00c4").to be_unroutable }
  it { expect(patch:  "/territoires/communes/9c6c00c4").to route_to("territories/communes#update", id: "9c6c00c4") }
  it { expect(delete: "/territoires/communes/9c6c00c4").to be_unroutable }

  it { expect(get:    "/territoires/communes/9c6c00c4/edit").to      route_to("territories/communes#edit", id: "9c6c00c4") }
  it { expect(get:    "/territoires/communes/9c6c00c4/remove").to    be_unroutable }
  it { expect(get:    "/territoires/communes/9c6c00c4/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/communes/9c6c00c4/undiscard").to be_unroutable }
end
