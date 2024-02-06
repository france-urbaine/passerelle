# frozen_string_literal: true

require "rails_helper"

RSpec.describe Territories::Communes::CollectivitiesController do
  let(:commune_id) { SecureRandom.uuid }
  let(:id)         { SecureRandom.uuid }

  it { expect(get:    "/territoires/communes/#{commune_id}/collectivites").to route_to("territories/communes/collectivities#index", commune_id:) }
  it { expect(post:   "/territoires/communes/#{commune_id}/collectivites").to be_unroutable }
  it { expect(patch:  "/territoires/communes/#{commune_id}/collectivites").to be_unroutable }
  it { expect(delete: "/territoires/communes/#{commune_id}/collectivites").to be_unroutable }

  it { expect(get:    "/territoires/communes/#{commune_id}/collectivites/new").to       be_unroutable }
  it { expect(get:    "/territoires/communes/#{commune_id}/collectivites/edit").to      be_unroutable }
  it { expect(get:    "/territoires/communes/#{commune_id}/collectivites/remove").to    be_unroutable }
  it { expect(get:    "/territoires/communes/#{commune_id}/collectivites/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/communes/#{commune_id}/collectivites/undiscard").to be_unroutable }

  it { expect(get:    "/territoires/communes/#{commune_id}/collectivites/#{id}").to be_unroutable }
  it { expect(post:   "/territoires/communes/#{commune_id}/collectivites/#{id}").to be_unroutable }
  it { expect(patch:  "/territoires/communes/#{commune_id}/collectivites/#{id}").to be_unroutable }
  it { expect(delete: "/territoires/communes/#{commune_id}/collectivites/#{id}").to be_unroutable }

  it { expect(get:    "/territoires/communes/#{commune_id}/collectivites/#{id}/edit").to      be_unroutable }
  it { expect(get:    "/territoires/communes/#{commune_id}/collectivites/#{id}/remove").to    be_unroutable }
  it { expect(get:    "/territoires/communes/#{commune_id}/collectivites/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/communes/#{commune_id}/collectivites/#{id}/undiscard").to be_unroutable }
end
