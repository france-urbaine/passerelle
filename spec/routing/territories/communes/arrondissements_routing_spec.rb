# frozen_string_literal: true

require "rails_helper"

RSpec.describe Territories::Communes::ArrondissementsController do
  it { expect(get:    "/territoires/communes/9c6c00c4/arrondissements").to route_to("territories/communes/arrondissements#index", commune_id: "9c6c00c4") }
  it { expect(post:   "/territoires/communes/9c6c00c4/arrondissements").to be_unroutable }
  it { expect(patch:  "/territoires/communes/9c6c00c4/arrondissements").to be_unroutable }
  it { expect(delete: "/territoires/communes/9c6c00c4/arrondissements").to be_unroutable }

  it { expect(get:    "/territoires/communes/9c6c00c4/arrondissements/new").to       be_unroutable }
  it { expect(get:    "/territoires/communes/9c6c00c4/arrondissements/edit").to      be_unroutable }
  it { expect(get:    "/territoires/communes/9c6c00c4/arrondissements/remove").to    be_unroutable }
  it { expect(get:    "/territoires/communes/9c6c00c4/arrondissements/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/communes/9c6c00c4/arrondissements/undiscard").to be_unroutable }

  it { expect(get:    "/territoires/communes/9c6c00c4/arrondissements/b12170f4").to be_unroutable }
  it { expect(post:   "/territoires/communes/9c6c00c4/arrondissements/b12170f4").to be_unroutable }
  it { expect(patch:  "/territoires/communes/9c6c00c4/arrondissements/b12170f4").to be_unroutable }
  it { expect(delete: "/territoires/communes/9c6c00c4/arrondissements/b12170f4").to be_unroutable }

  it { expect(get:    "/territoires/communes/9c6c00c4/arrondissements/b12170f4/edit").to      be_unroutable }
  it { expect(get:    "/territoires/communes/9c6c00c4/arrondissements/b12170f4/remove").to    be_unroutable }
  it { expect(get:    "/territoires/communes/9c6c00c4/arrondissements/b12170f4/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/communes/9c6c00c4/arrondissements/b12170f4/undiscard").to be_unroutable }
end
