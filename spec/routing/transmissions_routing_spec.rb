# frozen_string_literal: true

require "rails_helper"

RSpec.describe TransmissionsController do
  let(:id) { SecureRandom.uuid }

  it { expect(get:    "/transmissions").to route_to("transmissions#show") }
  it { expect(post:   "/transmissions").to route_to("transmissions#create") }
  it { expect(delete: "/transmissions").to route_to("transmissions#destroy") }
  it { expect(patch:  "/transmissions").to be_unroutable }

  it { expect(post:   "/transmissions/complete").to  route_to("transmissions#complete") }
  it { expect(get:    "/transmissions/new").to       be_unroutable }
  it { expect(get:    "/transmissions/edit").to      be_unroutable }
  it { expect(get:    "/transmissions/remove").to    be_unroutable }
  it { expect(get:    "/transmissions/undiscard").to be_unroutable }
  it { expect(patch:  "/transmissions/undiscard").to be_unroutable }

  it { expect(get:    "/transmissions/#{id}").to be_unroutable }
  it { expect(post:   "/transmissions/#{id}").to be_unroutable }
  it { expect(patch:  "/transmissions/#{id}").to be_unroutable }
  it { expect(delete: "/transmissions/#{id}").to be_unroutable }

  it { expect(get:    "/transmissions/#{id}/edit").to      be_unroutable }
  it { expect(get:    "/transmissions/#{id}/remove").to    be_unroutable }
  it { expect(get:    "/transmissions/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "/transmissions/#{id}/undiscard").to be_unroutable }
end
