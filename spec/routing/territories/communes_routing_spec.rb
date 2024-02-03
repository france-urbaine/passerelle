# frozen_string_literal: true

require "rails_helper"

RSpec.describe Territories::CommunesController do
  let(:id) { SecureRandom.uuid }

  it { expect(get:    "/territoires/communes").to route_to("territories/communes#index") }
  it { expect(post:   "/territoires/communes").to be_unroutable }
  it { expect(patch:  "/territoires/communes").to be_unroutable }
  it { expect(delete: "/territoires/communes").to be_unroutable }

  it { expect(get:    "/territoires/communes/new").to       be_unroutable }
  it { expect(get:    "/territoires/communes/edit").to      be_unroutable }
  it { expect(get:    "/territoires/communes/remove").to    be_unroutable }
  it { expect(get:    "/territoires/communes/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/communes/undiscard").to be_unroutable }

  it { expect(get:    "/territoires/communes/#{id}").to route_to("territories/communes#show", id:) }
  it { expect(post:   "/territoires/communes/#{id}").to be_unroutable }
  it { expect(patch:  "/territoires/communes/#{id}").to route_to("territories/communes#update", id:) }
  it { expect(delete: "/territoires/communes/#{id}").to be_unroutable }

  it { expect(get:    "/territoires/communes/#{id}/edit").to      route_to("territories/communes#edit", id:) }
  it { expect(get:    "/territoires/communes/#{id}/remove").to    be_unroutable }
  it { expect(get:    "/territoires/communes/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/communes/#{id}/undiscard").to be_unroutable }
end
