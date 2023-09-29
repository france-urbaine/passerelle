# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReportsController do
  it { expect(get:    "/transmissions").to route_to("transmissions#show") }
  it { expect(post:   "/transmissions").to route_to("transmissions#create") }
  it { expect(patch:  "/transmissions").to be_unroutable }
  it { expect(delete: "/transmissions").to be_unroutable }

  it { expect(post:   "/transmissions/complete").to  route_to("transmissions#complete") }
  it { expect(get:    "/transmissions/new").to       be_unroutable }
  it { expect(get:    "/transmissions/edit").to      be_unroutable }
  it { expect(get:    "/transmissions/remove").to    be_unroutable }
  it { expect(get:    "/transmissions/undiscard").to be_unroutable }
  it { expect(patch:  "/transmissions/undiscard").to be_unroutable }

  it { expect(get:    "/transmissions/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to be_unroutable }
  it { expect(post:   "/transmissions/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to be_unroutable }
  it { expect(patch:  "/transmissions/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to be_unroutable }
  it { expect(delete: "/transmissions/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to be_unroutable }

  it { expect(get:    "/transmissions/9c6c00c4-0784-4ef8-8978-b1e0246882a7/edit").to      be_unroutable }
  it { expect(get:    "/transmissions/9c6c00c4-0784-4ef8-8978-b1e0246882a7/remove").to    be_unroutable }
  it { expect(get:    "/transmissions/9c6c00c4-0784-4ef8-8978-b1e0246882a7/undiscard").to be_unroutable }
  it { expect(patch:  "/transmissions/9c6c00c4-0784-4ef8-8978-b1e0246882a7/undiscard").to be_unroutable }
end
