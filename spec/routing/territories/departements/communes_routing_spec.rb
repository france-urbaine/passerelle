# frozen_string_literal: true

require "rails_helper"

RSpec.describe Territories::Departements::CommunesController do
  let(:departement_id) { SecureRandom.uuid }
  let(:id)             { SecureRandom.uuid }

  it { expect(get:    "/territoires/departements/#{departement_id}/communes").to route_to("territories/departements/communes#index", departement_id:) }
  it { expect(post:   "/territoires/departements/#{departement_id}/communes").to be_unroutable }
  it { expect(patch:  "/territoires/departements/#{departement_id}/communes").to be_unroutable }
  it { expect(delete: "/territoires/departements/#{departement_id}/communes").to be_unroutable }

  it { expect(get:    "/territoires/departements/#{departement_id}/communes/new").to       be_unroutable }
  it { expect(get:    "/territoires/departements/#{departement_id}/communes/edit").to      be_unroutable }
  it { expect(get:    "/territoires/departements/#{departement_id}/communes/remove").to    be_unroutable }
  it { expect(get:    "/territoires/departements/#{departement_id}/communes/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/departements/#{departement_id}/communes/undiscard").to be_unroutable }

  it { expect(get:    "/territoires/departements/#{departement_id}/communes/#{id}").to be_unroutable }
  it { expect(post:   "/territoires/departements/#{departement_id}/communes/#{id}").to be_unroutable }
  it { expect(patch:  "/territoires/departements/#{departement_id}/communes/#{id}").to be_unroutable }
  it { expect(delete: "/territoires/departements/#{departement_id}/communes/#{id}").to be_unroutable }

  it { expect(get:    "/territoires/departements/#{departement_id}/communes/#{id}/edit").to      be_unroutable }
  it { expect(get:    "/territoires/departements/#{departement_id}/communes/#{id}/remove").to    be_unroutable }
  it { expect(get:    "/territoires/departements/#{departement_id}/communes/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/departements/#{departement_id}/communes/#{id}/undiscard").to be_unroutable }
end
