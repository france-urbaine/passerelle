# frozen_string_literal: true

require "rails_helper"

RSpec.describe Territories::Regions::DDFIPsController do
  let(:region_id) { SecureRandom.uuid }
  let(:id)        { SecureRandom.uuid }

  it { expect(get:    "/territoires/regions/#{region_id}/ddfips").to route_to("territories/regions/ddfips#index", region_id:) }
  it { expect(post:   "/territoires/regions/#{region_id}/ddfips").to be_unroutable }
  it { expect(patch:  "/territoires/regions/#{region_id}/ddfips").to be_unroutable }
  it { expect(delete: "/territoires/regions/#{region_id}/ddfips").to be_unroutable }

  it { expect(get:    "/territoires/regions/#{region_id}/ddfips/new").to       be_unroutable }
  it { expect(get:    "/territoires/regions/#{region_id}/ddfips/edit").to      be_unroutable }
  it { expect(get:    "/territoires/regions/#{region_id}/ddfips/remove").to    be_unroutable }
  it { expect(get:    "/territoires/regions/#{region_id}/ddfips/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/regions/#{region_id}/ddfips/undiscard").to be_unroutable }

  it { expect(get:    "/territoires/regions/#{region_id}/ddfips/#{id}").to be_unroutable }
  it { expect(post:   "/territoires/regions/#{region_id}/ddfips/#{id}").to be_unroutable }
  it { expect(patch:  "/territoires/regions/#{region_id}/ddfips/#{id}").to be_unroutable }
  it { expect(delete: "/territoires/regions/#{region_id}/ddfips/#{id}").to be_unroutable }

  it { expect(get:    "/territoires/regions/#{region_id}/ddfips/#{id}/edit").to      be_unroutable }
  it { expect(get:    "/territoires/regions/#{region_id}/ddfips/#{id}/remove").to    be_unroutable }
  it { expect(get:    "/territoires/regions/#{region_id}/ddfips/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/regions/#{region_id}/ddfips/#{id}/undiscard").to be_unroutable }
end
