# frozen_string_literal: true

require "rails_helper"

RSpec.describe Territories::EPCIs::CollectivitiesController do
  let(:epci_id) { SecureRandom.uuid }
  let(:id)      { SecureRandom.uuid }

  it { expect(get:    "/territoires/epcis/#{epci_id}/collectivites").to route_to("territories/epcis/collectivities#index", epci_id:) }
  it { expect(post:   "/territoires/epcis/#{epci_id}/collectivites").to be_unroutable }
  it { expect(patch:  "/territoires/epcis/#{epci_id}/collectivites").to be_unroutable }
  it { expect(delete: "/territoires/epcis/#{epci_id}/collectivites").to be_unroutable }

  it { expect(get:    "/territoires/epcis/#{epci_id}/collectivites/new").to       be_unroutable }
  it { expect(get:    "/territoires/epcis/#{epci_id}/collectivites/edit").to      be_unroutable }
  it { expect(get:    "/territoires/epcis/#{epci_id}/collectivites/remove").to    be_unroutable }
  it { expect(get:    "/territoires/epcis/#{epci_id}/collectivites/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/epcis/#{epci_id}/collectivites/undiscard").to be_unroutable }

  it { expect(get:    "/territoires/epcis/#{epci_id}/collectivites/#{id}").to be_unroutable }
  it { expect(post:   "/territoires/epcis/#{epci_id}/collectivites/#{id}").to be_unroutable }
  it { expect(patch:  "/territoires/epcis/#{epci_id}/collectivites/#{id}").to be_unroutable }
  it { expect(delete: "/territoires/epcis/#{epci_id}/collectivites/#{id}").to be_unroutable }

  it { expect(get:    "/territoires/epcis/#{epci_id}/collectivites/#{id}/edit").to      be_unroutable }
  it { expect(get:    "/territoires/epcis/#{epci_id}/collectivites/#{id}/remove").to    be_unroutable }
  it { expect(get:    "/territoires/epcis/#{epci_id}/collectivites/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/epcis/#{epci_id}/collectivites/#{id}/undiscard").to be_unroutable }
end
