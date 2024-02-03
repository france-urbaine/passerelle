# frozen_string_literal: true

require "rails_helper"

RSpec.describe Territories::EPCIsController do
  let(:id) { SecureRandom.uuid }

  it { expect(get:    "/territoires/epcis").to route_to("territories/epcis#index") }
  it { expect(post:   "/territoires/epcis").to be_unroutable }
  it { expect(patch:  "/territoires/epcis").to be_unroutable }
  it { expect(delete: "/territoires/epcis").to be_unroutable }

  it { expect(get:    "/territoires/epcis/new").to       be_unroutable }
  it { expect(get:    "/territoires/epcis/edit").to      be_unroutable }
  it { expect(get:    "/territoires/epcis/remove").to    be_unroutable }
  it { expect(get:    "/territoires/epcis/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/epcis/undiscard").to be_unroutable }

  it { expect(get:    "/territoires/epcis/#{id}").to route_to("territories/epcis#show", id:) }
  it { expect(post:   "/territoires/epcis/#{id}").to be_unroutable }
  it { expect(patch:  "/territoires/epcis/#{id}").to route_to("territories/epcis#update", id:) }
  it { expect(delete: "/territoires/epcis/#{id}").to be_unroutable }

  it { expect(get:    "/territoires/epcis/#{id}/edit").to      route_to("territories/epcis#edit", id:) }
  it { expect(get:    "/territoires/epcis/#{id}/remove").to    be_unroutable }
  it { expect(get:    "/territoires/epcis/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/epcis/#{id}/undiscard").to be_unroutable }
end
