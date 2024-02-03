# frozen_string_literal: true

require "rails_helper"

RSpec.describe Territories::Departements::CollectivitiesController do
  let(:departement_id) { SecureRandom.uuid }
  let(:id)             { SecureRandom.uuid }

  it { expect(get:    "/territoires/departements/#{departement_id}/collectivites").to route_to("territories/departements/collectivities#index", departement_id:) }
  it { expect(post:   "/territoires/departements/#{departement_id}/collectivites").to be_unroutable }
  it { expect(patch:  "/territoires/departements/#{departement_id}/collectivites").to be_unroutable }
  it { expect(delete: "/territoires/departements/#{departement_id}/collectivites").to be_unroutable }

  it { expect(get:    "/territoires/departements/#{departement_id}/collectivites/new").to       be_unroutable }
  it { expect(get:    "/territoires/departements/#{departement_id}/collectivites/edit").to      be_unroutable }
  it { expect(get:    "/territoires/departements/#{departement_id}/collectivites/remove").to    be_unroutable }
  it { expect(get:    "/territoires/departements/#{departement_id}/collectivites/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/departements/#{departement_id}/collectivites/undiscard").to be_unroutable }

  it { expect(get:    "/territoires/departements/#{departement_id}/collectivites/#{id}").to be_unroutable }
  it { expect(post:   "/territoires/departements/#{departement_id}/collectivites/#{id}").to be_unroutable }
  it { expect(patch:  "/territoires/departements/#{departement_id}/collectivites/#{id}").to be_unroutable }
  it { expect(delete: "/territoires/departements/#{departement_id}/collectivites/#{id}").to be_unroutable }

  it { expect(get:    "/territoires/departements/#{departement_id}/collectivites/#{id}/edit").to      be_unroutable }
  it { expect(get:    "/territoires/departements/#{departement_id}/collectivites/#{id}/remove").to    be_unroutable }
  it { expect(get:    "/territoires/departements/#{departement_id}/collectivites/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/departements/#{departement_id}/collectivites/#{id}/undiscard").to be_unroutable }
end
