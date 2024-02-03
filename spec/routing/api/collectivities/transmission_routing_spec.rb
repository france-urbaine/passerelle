# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::TransmissionsController, :api do
  let(:collectivity_id) { SecureRandom.uuid }
  let(:id)              { SecureRandom.uuid }

  it { expect(get:    "http://api.example.com/collectivites/#{collectivity_id}/transmissions").to be_unroutable }
  it { expect(post:   "http://api.example.com/collectivites/#{collectivity_id}/transmissions").to route_to("api/transmissions#create", collectivity_id:) }
  it { expect(put:    "http://api.example.com/collectivites/#{collectivity_id}/transmissions").to be_unroutable }
  it { expect(patch:  "http://api.example.com/collectivites/#{collectivity_id}/transmissions").to be_unroutable }
  it { expect(delete: "http://api.example.com/collectivites/#{collectivity_id}/transmissions").to be_unroutable }

  it { expect(get:    "http://api.example.com/collectivites/#{collectivity_id}/transmissions/#{id}").to be_unroutable }
  it { expect(post:   "http://api.example.com/collectivites/#{collectivity_id}/transmissions/#{id}").to be_unroutable }
  it { expect(put:    "http://api.example.com/collectivites/#{collectivity_id}/transmissions/#{id}").to be_unroutable }
  it { expect(patch:  "http://api.example.com/collectivites/#{collectivity_id}/transmissions/#{id}").to be_unroutable }
  it { expect(delete: "http://api.example.com/collectivites/#{collectivity_id}/transmissions/#{id}").to be_unroutable }
end
