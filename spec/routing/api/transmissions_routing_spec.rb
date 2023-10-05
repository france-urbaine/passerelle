# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::TransmissionsController, :api do
  it { expect(get:    "http://api.example.com/transmissions").to be_unroutable }
  it { expect(post:   "http://api.example.com/transmissions").to be_unroutable }
  it { expect(put:    "http://api.example.com/transmissions").to be_unroutable }
  it { expect(patch:  "http://api.example.com/transmissions").to be_unroutable }
  it { expect(delete: "http://api.example.com/transmissions").to be_unroutable }

  it { expect(get:    "http://api.example.com/transmissions/9c6c00c4").to be_unroutable }
  it { expect(post:   "http://api.example.com/transmissions/9c6c00c4").to be_unroutable }
  it { expect(put:    "http://api.example.com/transmissions/9c6c00c4").to be_unroutable }
  it { expect(patch:  "http://api.example.com/transmissions/9c6c00c4").to be_unroutable }
  it { expect(delete: "http://api.example.com/transmissions/9c6c00c4").to be_unroutable }

  it { expect(get:    "http://api.example.com/transmissions/9c6c00c4/complete").to be_unroutable }
  it { expect(post:   "http://api.example.com/transmissions/9c6c00c4/complete").to be_unroutable }
  it { expect(put:    "http://api.example.com/transmissions/9c6c00c4/complete").to route_to("api/transmissions#complete", id: "9c6c00c4") }
  it { expect(patch:  "http://api.example.com/transmissions/9c6c00c4/complete").to be_unroutable }
  it { expect(delete: "http://api.example.com/transmissions/9c6c00c4/complete").to be_unroutable }
end
