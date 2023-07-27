# frozen_string_literal: true

require "rails_helper"

RSpec.describe Territories::Regions::DepartementsController do
  it { expect(get:    "/territoires/regions/9c6c00c4/departements").to route_to("territories/regions/departements#index", region_id: "9c6c00c4") }
  it { expect(post:   "/territoires/regions/9c6c00c4/departements").to be_unroutable }
  it { expect(patch:  "/territoires/regions/9c6c00c4/departements").to be_unroutable }
  it { expect(delete: "/territoires/regions/9c6c00c4/departements").to be_unroutable }

  it { expect(get:    "/territoires/regions/9c6c00c4/departements/new").to       be_unroutable }
  it { expect(get:    "/territoires/regions/9c6c00c4/departements/edit").to      be_unroutable }
  it { expect(get:    "/territoires/regions/9c6c00c4/departements/remove").to    be_unroutable }
  it { expect(get:    "/territoires/regions/9c6c00c4/departements/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/regions/9c6c00c4/departements/undiscard").to be_unroutable }

  it { expect(get:    "/territoires/regions/9c6c00c4/departements/b12170f4").to be_unroutable }
  it { expect(post:   "/territoires/regions/9c6c00c4/departements/b12170f4").to be_unroutable }
  it { expect(patch:  "/territoires/regions/9c6c00c4/departements/b12170f4").to be_unroutable }
  it { expect(delete: "/territoires/regions/9c6c00c4/departements/b12170f4").to be_unroutable }

  it { expect(get:    "/territoires/regions/9c6c00c4/departements/b12170f4/edit").to      be_unroutable }
  it { expect(get:    "/territoires/regions/9c6c00c4/departements/b12170f4/remove").to    be_unroutable }
  it { expect(get:    "/territoires/regions/9c6c00c4/departements/b12170f4/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/regions/9c6c00c4/departements/b12170f4/undiscard").to be_unroutable }
end
