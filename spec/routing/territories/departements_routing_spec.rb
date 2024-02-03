# frozen_string_literal: true

require "rails_helper"

RSpec.describe Territories::DepartementsController do
  let(:id) { SecureRandom.uuid }

  it { expect(get:    "/territoires/departements").to route_to("territories/departements#index") }
  it { expect(post:   "/territoires/departements").to be_unroutable }
  it { expect(patch:  "/territoires/departements").to be_unroutable }
  it { expect(delete: "/territoires/departements").to be_unroutable }

  it { expect(get:    "/territoires/departements/new").to       be_unroutable }
  it { expect(get:    "/territoires/departements/edit").to      be_unroutable }
  it { expect(get:    "/territoires/departements/remove").to    be_unroutable }
  it { expect(get:    "/territoires/departements/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/departements/undiscard").to be_unroutable }

  it { expect(get:    "/territoires/departements/#{id}").to route_to("territories/departements#show", id:) }
  it { expect(post:   "/territoires/departements/#{id}").to be_unroutable }
  it { expect(patch:  "/territoires/departements/#{id}").to route_to("territories/departements#update", id:) }
  it { expect(delete: "/territoires/departements/#{id}").to be_unroutable }

  it { expect(get:    "/territoires/departements/#{id}/edit").to      route_to("territories/departements#edit", id:) }
  it { expect(get:    "/territoires/departements/#{id}/remove").to    be_unroutable }
  it { expect(get:    "/territoires/departements/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/departements/#{id}/undiscard").to be_unroutable }
end
