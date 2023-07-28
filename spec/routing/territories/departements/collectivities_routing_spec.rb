# frozen_string_literal: true

require "rails_helper"

RSpec.describe Territories::Departements::CollectivitiesController do
  it { expect(get:    "/territoires/departements/9c6c00c4/collectivites").to route_to("territories/departements/collectivities#index", departement_id: "9c6c00c4") }
  it { expect(post:   "/territoires/departements/9c6c00c4/collectivites").to be_unroutable }
  it { expect(patch:  "/territoires/departements/9c6c00c4/collectivites").to be_unroutable }
  it { expect(delete: "/territoires/departements/9c6c00c4/collectivites").to be_unroutable }

  it { expect(get:    "/territoires/departements/9c6c00c4/collectivites/new").to       be_unroutable }
  it { expect(get:    "/territoires/departements/9c6c00c4/collectivites/edit").to      be_unroutable }
  it { expect(get:    "/territoires/departements/9c6c00c4/collectivites/remove").to    be_unroutable }
  it { expect(get:    "/territoires/departements/9c6c00c4/collectivites/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/departements/9c6c00c4/collectivites/undiscard").to be_unroutable }

  it { expect(get:    "/territoires/departements/9c6c00c4/collectivites/b12170f4").to be_unroutable }
  it { expect(post:   "/territoires/departements/9c6c00c4/collectivites/b12170f4").to be_unroutable }
  it { expect(patch:  "/territoires/departements/9c6c00c4/collectivites/b12170f4").to be_unroutable }
  it { expect(delete: "/territoires/departements/9c6c00c4/collectivites/b12170f4").to be_unroutable }

  it { expect(get:    "/territoires/departements/9c6c00c4/collectivites/b12170f4/edit").to      be_unroutable }
  it { expect(get:    "/territoires/departements/9c6c00c4/collectivites/b12170f4/remove").to    be_unroutable }
  it { expect(get:    "/territoires/departements/9c6c00c4/collectivites/b12170f4/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/departements/9c6c00c4/collectivites/b12170f4/undiscard").to be_unroutable }
end
