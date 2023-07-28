# frozen_string_literal: true

require "rails_helper"

RSpec.describe Territories::Communes::CollectivitiesController do
  it { expect(get:    "/territoires/communes/9c6c00c4/collectivites").to route_to("territories/communes/collectivities#index", commune_id: "9c6c00c4") }
  it { expect(post:   "/territoires/communes/9c6c00c4/collectivites").to be_unroutable }
  it { expect(patch:  "/territoires/communes/9c6c00c4/collectivites").to be_unroutable }
  it { expect(delete: "/territoires/communes/9c6c00c4/collectivites").to be_unroutable }

  it { expect(get:    "/territoires/communes/9c6c00c4/collectivites/new").to       be_unroutable }
  it { expect(get:    "/territoires/communes/9c6c00c4/collectivites/edit").to      be_unroutable }
  it { expect(get:    "/territoires/communes/9c6c00c4/collectivites/remove").to    be_unroutable }
  it { expect(get:    "/territoires/communes/9c6c00c4/collectivites/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/communes/9c6c00c4/collectivites/undiscard").to be_unroutable }

  it { expect(get:    "/territoires/communes/9c6c00c4/collectivites/b12170f4").to be_unroutable }
  it { expect(post:   "/territoires/communes/9c6c00c4/collectivites/b12170f4").to be_unroutable }
  it { expect(patch:  "/territoires/communes/9c6c00c4/collectivites/b12170f4").to be_unroutable }
  it { expect(delete: "/territoires/communes/9c6c00c4/collectivites/b12170f4").to be_unroutable }

  it { expect(get:    "/territoires/communes/9c6c00c4/collectivites/b12170f4/edit").to      be_unroutable }
  it { expect(get:    "/territoires/communes/9c6c00c4/collectivites/b12170f4/remove").to    be_unroutable }
  it { expect(get:    "/territoires/communes/9c6c00c4/collectivites/b12170f4/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/communes/9c6c00c4/collectivites/b12170f4/undiscard").to be_unroutable }
end
