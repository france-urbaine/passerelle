# frozen_string_literal: true

require "rails_helper"

RSpec.describe TerritoriesController do
  let(:id) { SecureRandom.uuid }

  it { expect(get:    "/territoires").to route_to("territories#index") }
  it { expect(post:   "/territoires").to be_unroutable }
  it { expect(patch:  "/territoires").to be_unroutable }
  it { expect(delete: "/territoires").to be_unroutable }

  it { expect(get:    "/territoires/new").to       be_unroutable }
  it { expect(get:    "/territoires/edit").to      be_unroutable }
  it { expect(get:    "/territoires/remove").to    be_unroutable }
  it { expect(get:    "/territoires/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/undiscard").to be_unroutable }

  it { expect(get:    "/territoires/#{id}").to be_unroutable }
  it { expect(post:   "/territoires/#{id}").to be_unroutable }
  it { expect(patch:  "/territoires/#{id}").to be_unroutable }
  it { expect(delete: "/territoires/#{id}").to be_unroutable }

  it { expect(get:    "/territoires/#{id}/edit").to      be_unroutable }
  it { expect(get:    "/territoires/#{id}/remove").to    be_unroutable }
  it { expect(get:    "/territoires/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/#{id}/undiscard").to be_unroutable }
end
