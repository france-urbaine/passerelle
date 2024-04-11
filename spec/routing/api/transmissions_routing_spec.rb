# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::TransmissionsController do
  let(:id) { SecureRandom.uuid }

  it { expect(get:    "http://api.example.com/transmissions").to be_unroutable }
  it { expect(post:   "http://api.example.com/transmissions").to be_unroutable }
  it { expect(put:    "http://api.example.com/transmissions").to be_unroutable }
  it { expect(patch:  "http://api.example.com/transmissions").to be_unroutable }
  it { expect(delete: "http://api.example.com/transmissions").to be_unroutable }

  it { expect(get:    "http://api.example.com/transmissions/#{id}").to be_unroutable }
  it { expect(post:   "http://api.example.com/transmissions/#{id}").to be_unroutable }
  it { expect(put:    "http://api.example.com/transmissions/#{id}").to be_unroutable }
  it { expect(patch:  "http://api.example.com/transmissions/#{id}").to be_unroutable }
  it { expect(delete: "http://api.example.com/transmissions/#{id}").to be_unroutable }

  it { expect(get:    "http://api.example.com/transmissions/#{id}/finalisation").to be_unroutable }
  it { expect(post:   "http://api.example.com/transmissions/#{id}/finalisation").to be_unroutable }
  it { expect(put:    "http://api.example.com/transmissions/#{id}/finalisation").to route_to("api/transmissions#complete", id:) }
  it { expect(patch:  "http://api.example.com/transmissions/#{id}/finalisation").to be_unroutable }
  it { expect(delete: "http://api.example.com/transmissions/#{id}/finalisation").to be_unroutable }
end
