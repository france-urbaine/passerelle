# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::CollectivitiesController, :api do
  let(:id) { SecureRandom.uuid }

  it { expect(get:    "http://api.example.com/collectivites").to route_to("api/collectivities#index") }
  it { expect(post:   "http://api.example.com/collectivites").to be_unroutable }
  it { expect(put:    "http://api.example.com/collectivites").to be_unroutable }
  it { expect(patch:  "http://api.example.com/collectivites").to be_unroutable }
  it { expect(delete: "http://api.example.com/collectivites").to be_unroutable }

  it { expect(get:    "http://api.example.com/collectivites/#{id}").to be_unroutable }
  it { expect(post:   "http://api.example.com/collectivites/#{id}").to be_unroutable }
  it { expect(put:    "http://api.example.com/collectivites/#{id}").to be_unroutable }
  it { expect(patch:  "http://api.example.com/collectivites/#{id}").to be_unroutable }
  it { expect(delete: "http://api.example.com/collectivites/#{id}").to be_unroutable }
end
