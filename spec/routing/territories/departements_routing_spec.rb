# frozen_string_literal: true

require "rails_helper"

RSpec.describe Territories::DepartementsController do
  it { expect(get:    "/territoires/departements").to route_to("territories/departements#index") }
  it { expect(post:   "/territoires/departements").to be_unroutable }
  it { expect(patch:  "/territoires/departements").to be_unroutable }
  it { expect(delete: "/territoires/departements").to be_unroutable }

  it { expect(get:    "/territoires/departements/new").to       be_unroutable }
  it { expect(get:    "/territoires/departements/edit").to      be_unroutable }
  it { expect(get:    "/territoires/departements/remove").to    be_unroutable }
  it { expect(get:    "/territoires/departements/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/departements/undiscard").to be_unroutable }

  it { expect(get:    "/territoires/departements/9c6c00c4").to route_to("territories/departements#show", id: "9c6c00c4") }
  it { expect(post:   "/territoires/departements/9c6c00c4").to be_unroutable }
  it { expect(patch:  "/territoires/departements/9c6c00c4").to route_to("territories/departements#update", id: "9c6c00c4") }
  it { expect(delete: "/territoires/departements/9c6c00c4").to be_unroutable }

  it { expect(get:    "/territoires/departements/9c6c00c4/edit").to      route_to("territories/departements#edit", id: "9c6c00c4") }
  it { expect(get:    "/territoires/departements/9c6c00c4/remove").to    be_unroutable }
  it { expect(get:    "/territoires/departements/9c6c00c4/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/departements/9c6c00c4/undiscard").to be_unroutable }
end
