# frozen_string_literal: true

require "rails_helper"

RSpec.describe Territories::Communes::ArrondissementsController do
  let(:commune_id) { SecureRandom.uuid }
  let(:id)         { SecureRandom.uuid }

  it { expect(get:    "/territoires/communes/#{commune_id}/arrondissements").to route_to("territories/communes/arrondissements#index", commune_id:) }
  it { expect(post:   "/territoires/communes/#{commune_id}/arrondissements").to be_unroutable }
  it { expect(patch:  "/territoires/communes/#{commune_id}/arrondissements").to be_unroutable }
  it { expect(delete: "/territoires/communes/#{commune_id}/arrondissements").to be_unroutable }

  it { expect(get:    "/territoires/communes/#{commune_id}/arrondissements/new").to       be_unroutable }
  it { expect(get:    "/territoires/communes/#{commune_id}/arrondissements/edit").to      be_unroutable }
  it { expect(get:    "/territoires/communes/#{commune_id}/arrondissements/remove").to    be_unroutable }
  it { expect(get:    "/territoires/communes/#{commune_id}/arrondissements/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/communes/#{commune_id}/arrondissements/undiscard").to be_unroutable }

  it { expect(get:    "/territoires/communes/#{commune_id}/arrondissements/#{id}").to be_unroutable }
  it { expect(post:   "/territoires/communes/#{commune_id}/arrondissements/#{id}").to be_unroutable }
  it { expect(patch:  "/territoires/communes/#{commune_id}/arrondissements/#{id}").to be_unroutable }
  it { expect(delete: "/territoires/communes/#{commune_id}/arrondissements/#{id}").to be_unroutable }

  it { expect(get:    "/territoires/communes/#{commune_id}/arrondissements/#{id}/edit").to      be_unroutable }
  it { expect(get:    "/territoires/communes/#{commune_id}/arrondissements/#{id}/remove").to    be_unroutable }
  it { expect(get:    "/territoires/communes/#{commune_id}/arrondissements/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/communes/#{commune_id}/arrondissements/#{id}/undiscard").to be_unroutable }
end
