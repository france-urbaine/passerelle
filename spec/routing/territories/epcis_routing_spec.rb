# frozen_string_literal: true

require "rails_helper"

RSpec.describe Territories::EPCIsController do
  it { expect(get:    "/territoires/epcis").to route_to("territories/epcis#index") }
  it { expect(post:   "/territoires/epcis").to be_unroutable }
  it { expect(patch:  "/territoires/epcis").to be_unroutable }
  it { expect(delete: "/territoires/epcis").to be_unroutable }

  it { expect(get:    "/territoires/epcis/new").to       be_unroutable }
  it { expect(get:    "/territoires/epcis/edit").to      be_unroutable }
  it { expect(get:    "/territoires/epcis/remove").to    be_unroutable }
  it { expect(get:    "/territoires/epcis/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/epcis/undiscard").to be_unroutable }

  it { expect(get:    "/territoires/epcis/9c6c00c4").to route_to("territories/epcis#show", id: "9c6c00c4") }
  it { expect(post:   "/territoires/epcis/9c6c00c4").to be_unroutable }
  it { expect(patch:  "/territoires/epcis/9c6c00c4").to route_to("territories/epcis#update", id: "9c6c00c4") }
  it { expect(delete: "/territoires/epcis/9c6c00c4").to be_unroutable }

  it { expect(get:    "/territoires/epcis/9c6c00c4/edit").to      route_to("territories/epcis#edit", id: "9c6c00c4") }
  it { expect(get:    "/territoires/epcis/9c6c00c4/remove").to    be_unroutable }
  it { expect(get:    "/territoires/epcis/9c6c00c4/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/epcis/9c6c00c4/undiscard").to be_unroutable }
end
