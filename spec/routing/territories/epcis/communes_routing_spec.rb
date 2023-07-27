# frozen_string_literal: true

require "rails_helper"

RSpec.describe Territories::EPCIs::CommunesController do
  it { expect(get:    "/territoires/epcis/9c6c00c4/communes").to route_to("territories/epcis/communes#index", epci_id: "9c6c00c4") }
  it { expect(post:   "/territoires/epcis/9c6c00c4/communes").to be_unroutable }
  it { expect(patch:  "/territoires/epcis/9c6c00c4/communes").to be_unroutable }
  it { expect(delete: "/territoires/epcis/9c6c00c4/communes").to be_unroutable }

  it { expect(get:    "/territoires/epcis/9c6c00c4/communes/new").to       be_unroutable }
  it { expect(get:    "/territoires/epcis/9c6c00c4/communes/edit").to      be_unroutable }
  it { expect(get:    "/territoires/epcis/9c6c00c4/communes/remove").to    be_unroutable }
  it { expect(get:    "/territoires/epcis/9c6c00c4/communes/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/epcis/9c6c00c4/communes/undiscard").to be_unroutable }

  it { expect(get:    "/territoires/epcis/9c6c00c4/communes/b12170f4").to be_unroutable }
  it { expect(post:   "/territoires/epcis/9c6c00c4/communes/b12170f4").to be_unroutable }
  it { expect(patch:  "/territoires/epcis/9c6c00c4/communes/b12170f4").to be_unroutable }
  it { expect(delete: "/territoires/epcis/9c6c00c4/communes/b12170f4").to be_unroutable }

  it { expect(get:    "/territoires/epcis/9c6c00c4/communes/b12170f4/edit").to      be_unroutable }
  it { expect(get:    "/territoires/epcis/9c6c00c4/communes/b12170f4/remove").to    be_unroutable }
  it { expect(get:    "/territoires/epcis/9c6c00c4/communes/b12170f4/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/epcis/9c6c00c4/communes/b12170f4/undiscard").to be_unroutable }
end
