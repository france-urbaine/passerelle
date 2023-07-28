# frozen_string_literal: true

require "rails_helper"

RSpec.describe Territories::Departements::CommunesController do
  it { expect(get:    "/territoires/departements/9c6c00c4/communes").to route_to("territories/departements/communes#index", departement_id: "9c6c00c4") }
  it { expect(post:   "/territoires/departements/9c6c00c4/communes").to be_unroutable }
  it { expect(patch:  "/territoires/departements/9c6c00c4/communes").to be_unroutable }
  it { expect(delete: "/territoires/departements/9c6c00c4/communes").to be_unroutable }

  it { expect(get:    "/territoires/departements/9c6c00c4/communes/new").to       be_unroutable }
  it { expect(get:    "/territoires/departements/9c6c00c4/communes/edit").to      be_unroutable }
  it { expect(get:    "/territoires/departements/9c6c00c4/communes/remove").to    be_unroutable }
  it { expect(get:    "/territoires/departements/9c6c00c4/communes/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/departements/9c6c00c4/communes/undiscard").to be_unroutable }

  it { expect(get:    "/territoires/departements/9c6c00c4/communes/b12170f4").to be_unroutable }
  it { expect(post:   "/territoires/departements/9c6c00c4/communes/b12170f4").to be_unroutable }
  it { expect(patch:  "/territoires/departements/9c6c00c4/communes/b12170f4").to be_unroutable }
  it { expect(delete: "/territoires/departements/9c6c00c4/communes/b12170f4").to be_unroutable }

  it { expect(get:    "/territoires/departements/9c6c00c4/communes/b12170f4/edit").to      be_unroutable }
  it { expect(get:    "/territoires/departements/9c6c00c4/communes/b12170f4/remove").to    be_unroutable }
  it { expect(get:    "/territoires/departements/9c6c00c4/communes/b12170f4/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/departements/9c6c00c4/communes/b12170f4/undiscard").to be_unroutable }
end
