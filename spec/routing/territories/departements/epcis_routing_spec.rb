# frozen_string_literal: true

require "rails_helper"

RSpec.describe Territories::Departements::EPCIsController do
  it { expect(get:    "/territoires/departements/9c6c00c4/epcis").to route_to("territories/departements/epcis#index", departement_id: "9c6c00c4") }
  it { expect(post:   "/territoires/departements/9c6c00c4/epcis").to be_unroutable }
  it { expect(patch:  "/territoires/departements/9c6c00c4/epcis").to be_unroutable }
  it { expect(delete: "/territoires/departements/9c6c00c4/epcis").to be_unroutable }

  it { expect(get:    "/territoires/departements/9c6c00c4/epcis/new").to       be_unroutable }
  it { expect(get:    "/territoires/departements/9c6c00c4/epcis/edit").to      be_unroutable }
  it { expect(get:    "/territoires/departements/9c6c00c4/epcis/remove").to    be_unroutable }
  it { expect(get:    "/territoires/departements/9c6c00c4/epcis/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/departements/9c6c00c4/epcis/undiscard").to be_unroutable }

  it { expect(get:    "/territoires/departements/9c6c00c4/epcis/b12170f4").to be_unroutable }
  it { expect(post:   "/territoires/departements/9c6c00c4/epcis/b12170f4").to be_unroutable }
  it { expect(patch:  "/territoires/departements/9c6c00c4/epcis/b12170f4").to be_unroutable }
  it { expect(delete: "/territoires/departements/9c6c00c4/epcis/b12170f4").to be_unroutable }

  it { expect(get:    "/territoires/departements/9c6c00c4/epcis/b12170f4/edit").to      be_unroutable }
  it { expect(get:    "/territoires/departements/9c6c00c4/epcis/b12170f4/remove").to    be_unroutable }
  it { expect(get:    "/territoires/departements/9c6c00c4/epcis/b12170f4/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/departements/9c6c00c4/epcis/b12170f4/undiscard").to be_unroutable }
end
