# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::ReportsController do
  let(:id) { SecureRandom.uuid }

  it { expect(get:    "http://api.example.com/signalements").to be_unroutable }
  it { expect(post:   "http://api.example.com/signalements").to be_unroutable }
  it { expect(put:    "http://api.example.com/signalements").to be_unroutable }
  it { expect(patch:  "http://api.example.com/signalements").to be_unroutable }
  it { expect(delete: "http://api.example.com/signalements").to be_unroutable }

  it { expect(get:    "http://api.example.com/signalements/#{id}").to be_unroutable }
  it { expect(post:   "http://api.example.com/signalements/#{id}").to be_unroutable }
  it { expect(put:    "http://api.example.com/signalements/#{id}").to be_unroutable }
  it { expect(patch:  "http://api.example.com/signalements/#{id}").to be_unroutable }
  it { expect(delete: "http://api.example.com/signalements/#{id}").to be_unroutable }
end
