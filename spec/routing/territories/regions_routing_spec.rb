# frozen_string_literal: true

require "rails_helper"

RSpec.describe Territories::RegionsController do
  let(:id) { SecureRandom.uuid }

  it { expect(get:    "/territoires/regions").to route_to("territories/regions#index") }
  it { expect(post:   "/territoires/regions").to be_unroutable }
  it { expect(patch:  "/territoires/regions").to be_unroutable }
  it { expect(delete: "/territoires/regions").to be_unroutable }

  it { expect(get:    "/territoires/regions/new").to       be_unroutable }
  it { expect(get:    "/territoires/regions/edit").to      be_unroutable }
  it { expect(get:    "/territoires/regions/remove").to    be_unroutable }
  it { expect(get:    "/territoires/regions/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/regions/undiscard").to be_unroutable }

  it { expect(get:    "/territoires/regions/#{id}").to route_to("territories/regions#show", id:) }
  it { expect(post:   "/territoires/regions/#{id}").to be_unroutable }
  it { expect(patch:  "/territoires/regions/#{id}").to route_to("territories/regions#update", id:) }
  it { expect(delete: "/territoires/regions/#{id}").to be_unroutable }

  it { expect(get:    "/territoires/regions/#{id}/edit").to      route_to("territories/regions#edit", id:) }
  it { expect(get:    "/territoires/regions/#{id}/remove").to    be_unroutable }
  it { expect(get:    "/territoires/regions/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/regions/#{id}/undiscard").to be_unroutable }
end
