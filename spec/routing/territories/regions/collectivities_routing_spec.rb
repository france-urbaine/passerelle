# frozen_string_literal: true

require "rails_helper"

RSpec.describe Territories::Regions::CollectivitiesController do
  let(:region_id) { SecureRandom.uuid }
  let(:id)        { SecureRandom.uuid }

  it { expect(get:    "/territoires/regions/#{region_id}/collectivites").to route_to("territories/regions/collectivities#index", region_id:) }
  it { expect(post:   "/territoires/regions/#{region_id}/collectivites").to be_unroutable }
  it { expect(patch:  "/territoires/regions/#{region_id}/collectivites").to be_unroutable }
  it { expect(delete: "/territoires/regions/#{region_id}/collectivites").to be_unroutable }

  it { expect(get:    "/territoires/regions/#{region_id}/collectivites/new").to       be_unroutable }
  it { expect(get:    "/territoires/regions/#{region_id}/collectivites/edit").to      be_unroutable }
  it { expect(get:    "/territoires/regions/#{region_id}/collectivites/remove").to    be_unroutable }
  it { expect(get:    "/territoires/regions/#{region_id}/collectivites/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/regions/#{region_id}/collectivites/undiscard").to be_unroutable }

  it { expect(get:    "/territoires/regions/#{region_id}/collectivites/#{id}").to be_unroutable }
  it { expect(post:   "/territoires/regions/#{region_id}/collectivites/#{id}").to be_unroutable }
  it { expect(patch:  "/territoires/regions/#{region_id}/collectivites/#{id}").to be_unroutable }
  it { expect(delete: "/territoires/regions/#{region_id}/collectivites/#{id}").to be_unroutable }

  it { expect(get:    "/territoires/regions/#{region_id}/collectivites/#{id}/edit").to      be_unroutable }
  it { expect(get:    "/territoires/regions/#{region_id}/collectivites/#{id}/remove").to    be_unroutable }
  it { expect(get:    "/territoires/regions/#{region_id}/collectivites/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/regions/#{region_id}/collectivites/#{id}/undiscard").to be_unroutable }
end
