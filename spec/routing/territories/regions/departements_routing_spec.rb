# frozen_string_literal: true

require "rails_helper"

RSpec.describe Territories::Regions::DepartementsController do
  let(:region_id) { SecureRandom.uuid }
  let(:id)        { SecureRandom.uuid }

  it { expect(get:    "/territoires/regions/#{region_id}/departements").to route_to("territories/regions/departements#index", region_id:) }
  it { expect(post:   "/territoires/regions/#{region_id}/departements").to be_unroutable }
  it { expect(patch:  "/territoires/regions/#{region_id}/departements").to be_unroutable }
  it { expect(delete: "/territoires/regions/#{region_id}/departements").to be_unroutable }

  it { expect(get:    "/territoires/regions/#{region_id}/departements/new").to       be_unroutable }
  it { expect(get:    "/territoires/regions/#{region_id}/departements/edit").to      be_unroutable }
  it { expect(get:    "/territoires/regions/#{region_id}/departements/remove").to    be_unroutable }
  it { expect(get:    "/territoires/regions/#{region_id}/departements/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/regions/#{region_id}/departements/undiscard").to be_unroutable }

  it { expect(get:    "/territoires/regions/#{region_id}/departements/#{id}").to be_unroutable }
  it { expect(post:   "/territoires/regions/#{region_id}/departements/#{id}").to be_unroutable }
  it { expect(patch:  "/territoires/regions/#{region_id}/departements/#{id}").to be_unroutable }
  it { expect(delete: "/territoires/regions/#{region_id}/departements/#{id}").to be_unroutable }

  it { expect(get:    "/territoires/regions/#{region_id}/departements/#{id}/edit").to      be_unroutable }
  it { expect(get:    "/territoires/regions/#{region_id}/departements/#{id}/remove").to    be_unroutable }
  it { expect(get:    "/territoires/regions/#{region_id}/departements/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/regions/#{region_id}/departements/#{id}/undiscard").to be_unroutable }
end
