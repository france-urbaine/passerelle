# frozen_string_literal: true

require "rails_helper"

RSpec.describe Territories::Departements::EPCIsController do
  let(:departement_id) { SecureRandom.uuid }
  let(:id)             { SecureRandom.uuid }

  it { expect(get:    "/territoires/departements/#{departement_id}/epcis").to route_to("territories/departements/epcis#index", departement_id:) }
  it { expect(post:   "/territoires/departements/#{departement_id}/epcis").to be_unroutable }
  it { expect(patch:  "/territoires/departements/#{departement_id}/epcis").to be_unroutable }
  it { expect(delete: "/territoires/departements/#{departement_id}/epcis").to be_unroutable }

  it { expect(get:    "/territoires/departements/#{departement_id}/epcis/new").to       be_unroutable }
  it { expect(get:    "/territoires/departements/#{departement_id}/epcis/edit").to      be_unroutable }
  it { expect(get:    "/territoires/departements/#{departement_id}/epcis/remove").to    be_unroutable }
  it { expect(get:    "/territoires/departements/#{departement_id}/epcis/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/departements/#{departement_id}/epcis/undiscard").to be_unroutable }

  it { expect(get:    "/territoires/departements/#{departement_id}/epcis/#{id}").to be_unroutable }
  it { expect(post:   "/territoires/departements/#{departement_id}/epcis/#{id}").to be_unroutable }
  it { expect(patch:  "/territoires/departements/#{departement_id}/epcis/#{id}").to be_unroutable }
  it { expect(delete: "/territoires/departements/#{departement_id}/epcis/#{id}").to be_unroutable }

  it { expect(get:    "/territoires/departements/#{departement_id}/epcis/#{id}/edit").to      be_unroutable }
  it { expect(get:    "/territoires/departements/#{departement_id}/epcis/#{id}/remove").to    be_unroutable }
  it { expect(get:    "/territoires/departements/#{departement_id}/epcis/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/departements/#{departement_id}/epcis/#{id}/undiscard").to be_unroutable }
end
