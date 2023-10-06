# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::TransmissionsController do
  it { expect(get:    "/api/transmissions").to be_unroutable }
  it { expect(post:   "/api/transmissions").to be_unroutable }
  it { expect(put:    "/api/transmissions").to be_unroutable }
  it { expect(patch:  "/api/transmissions").to be_unroutable }
  it { expect(delete: "/api/transmissions").to be_unroutable }

  it { expect(get:    "/api/transmissions/9c6c00c4").to be_unroutable }
  it { expect(post:   "/api/transmissions/9c6c00c4").to be_unroutable }
  it { expect(put:    "/api/transmissions/9c6c00c4").to be_unroutable }
  it { expect(patch:  "/api/transmissions/9c6c00c4").to be_unroutable }
  it { expect(delete: "/api/transmissions/9c6c00c4").to be_unroutable }

  it { expect(get:    "/api/transmissions/9c6c00c4/complete").to be_unroutable }
  it { expect(post:   "/api/transmissions/9c6c00c4/complete").to be_unroutable }
  it { expect(put:    "/api/transmissions/9c6c00c4/complete").to route_to("api/transmissions#complete", id: "9c6c00c4") }
  it { expect(patch:  "/api/transmissions/9c6c00c4/complete").to be_unroutable }
  it { expect(delete: "/api/transmissions/9c6c00c4/complete").to be_unroutable }
end
