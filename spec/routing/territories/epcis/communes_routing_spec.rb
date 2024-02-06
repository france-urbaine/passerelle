# frozen_string_literal: true

require "rails_helper"

RSpec.describe Territories::EPCIs::CommunesController do
  let(:epci_id) { SecureRandom.uuid }
  let(:id)      { SecureRandom.uuid }

  it { expect(get:    "/territoires/epcis/#{epci_id}/communes").to route_to("territories/epcis/communes#index", epci_id:) }
  it { expect(post:   "/territoires/epcis/#{epci_id}/communes").to be_unroutable }
  it { expect(patch:  "/territoires/epcis/#{epci_id}/communes").to be_unroutable }
  it { expect(delete: "/territoires/epcis/#{epci_id}/communes").to be_unroutable }

  it { expect(get:    "/territoires/epcis/#{epci_id}/communes/new").to       be_unroutable }
  it { expect(get:    "/territoires/epcis/#{epci_id}/communes/edit").to      be_unroutable }
  it { expect(get:    "/territoires/epcis/#{epci_id}/communes/remove").to    be_unroutable }
  it { expect(get:    "/territoires/epcis/#{epci_id}/communes/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/epcis/#{epci_id}/communes/undiscard").to be_unroutable }

  it { expect(get:    "/territoires/epcis/#{epci_id}/communes/#{id}").to be_unroutable }
  it { expect(post:   "/territoires/epcis/#{epci_id}/communes/#{id}").to be_unroutable }
  it { expect(patch:  "/territoires/epcis/#{epci_id}/communes/#{id}").to be_unroutable }
  it { expect(delete: "/territoires/epcis/#{epci_id}/communes/#{id}").to be_unroutable }

  it { expect(get:    "/territoires/epcis/#{epci_id}/communes/#{id}/edit").to      be_unroutable }
  it { expect(get:    "/territoires/epcis/#{epci_id}/communes/#{id}/remove").to    be_unroutable }
  it { expect(get:    "/territoires/epcis/#{epci_id}/communes/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/epcis/#{epci_id}/communes/#{id}/undiscard").to be_unroutable }
end
