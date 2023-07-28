# frozen_string_literal: true

require "rails_helper"

RSpec.describe Territories::RegionsController do
  it { expect(get:    "/territoires/regions").to route_to("territories/regions#index") }
  it { expect(post:   "/territoires/regions").to be_unroutable }
  it { expect(patch:  "/territoires/regions").to be_unroutable }
  it { expect(delete: "/territoires/regions").to be_unroutable }

  it { expect(get:    "/territoires/regions/new").to       be_unroutable }
  it { expect(get:    "/territoires/regions/edit").to      be_unroutable }
  it { expect(get:    "/territoires/regions/remove").to    be_unroutable }
  it { expect(get:    "/territoires/regions/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/regions/undiscard").to be_unroutable }

  it { expect(get:    "/territoires/regions/9c6c00c4").to route_to("territories/regions#show", id: "9c6c00c4") }
  it { expect(post:   "/territoires/regions/9c6c00c4").to be_unroutable }
  it { expect(patch:  "/territoires/regions/9c6c00c4").to route_to("territories/regions#update", id: "9c6c00c4") }
  it { expect(delete: "/territoires/regions/9c6c00c4").to be_unroutable }

  it { expect(get:    "/territoires/regions/9c6c00c4/edit").to      route_to("territories/regions#edit", id: "9c6c00c4") }
  it { expect(get:    "/territoires/regions/9c6c00c4/remove").to    be_unroutable }
  it { expect(get:    "/territoires/regions/9c6c00c4/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/regions/9c6c00c4/undiscard").to be_unroutable }
end
