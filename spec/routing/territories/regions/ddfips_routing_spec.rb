# frozen_string_literal: true

require "rails_helper"

RSpec.describe Territories::Regions::DDFIPsController do
  it { expect(get:    "/territoires/regions/9c6c00c4/ddfips").to route_to("territories/regions/ddfips#index", region_id: "9c6c00c4") }
  it { expect(post:   "/territoires/regions/9c6c00c4/ddfips").to be_unroutable }
  it { expect(patch:  "/territoires/regions/9c6c00c4/ddfips").to be_unroutable }
  it { expect(delete: "/territoires/regions/9c6c00c4/ddfips").to be_unroutable }

  it { expect(get:    "/territoires/regions/9c6c00c4/ddfips/new").to       be_unroutable }
  it { expect(get:    "/territoires/regions/9c6c00c4/ddfips/edit").to      be_unroutable }
  it { expect(get:    "/territoires/regions/9c6c00c4/ddfips/remove").to    be_unroutable }
  it { expect(get:    "/territoires/regions/9c6c00c4/ddfips/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/regions/9c6c00c4/ddfips/undiscard").to be_unroutable }

  it { expect(get:    "/territoires/regions/9c6c00c4/ddfips/b12170f4").to be_unroutable }
  it { expect(post:   "/territoires/regions/9c6c00c4/ddfips/b12170f4").to be_unroutable }
  it { expect(patch:  "/territoires/regions/9c6c00c4/ddfips/b12170f4").to be_unroutable }
  it { expect(delete: "/territoires/regions/9c6c00c4/ddfips/b12170f4").to be_unroutable }

  it { expect(get:    "/territoires/regions/9c6c00c4/ddfips/b12170f4/edit").to      be_unroutable }
  it { expect(get:    "/territoires/regions/9c6c00c4/ddfips/b12170f4/remove").to    be_unroutable }
  it { expect(get:    "/territoires/regions/9c6c00c4/ddfips/b12170f4/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/regions/9c6c00c4/ddfips/b12170f4/undiscard").to be_unroutable }
end
