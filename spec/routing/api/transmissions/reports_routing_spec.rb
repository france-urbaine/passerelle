# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::ReportsController do
  let(:transmission_id) { SecureRandom.uuid }
  let(:id)              { SecureRandom.uuid }

  it { expect(get:    "http://api.example.com/transmissions/#{transmission_id}/signalements").to be_unroutable }
  it { expect(post:   "http://api.example.com/transmissions/#{transmission_id}/signalements").to route_to("api/reports#create", transmission_id:) }
  it { expect(patch:  "http://api.example.com/transmissions/#{transmission_id}/signalements").to be_unroutable }
  it { expect(delete: "http://api.example.com/transmissions/#{transmission_id}/signalements").to be_unroutable }

  it { expect(get:    "http://api.example.com/transmissions/#{transmission_id}/signalements/#{id}").to be_unroutable }
  it { expect(post:   "http://api.example.com/transmissions/#{transmission_id}/signalements/#{id}").to be_unroutable }
  it { expect(patch:  "http://api.example.com/transmissions/#{transmission_id}/signalements/#{id}").to be_unroutable }
  it { expect(delete: "http://api.example.com/transmissions/#{transmission_id}/signalements/#{id}").to be_unroutable }
end
