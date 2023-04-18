# frozen_string_literal: true

require "rails_helper"

RSpec.describe RegionsController do
  it { expect(get:    "/regions").to route_to("regions#index") }
  it { expect(post:   "/regions").to be_unroutable }
  it { expect(patch:  "/regions").to be_unroutable }
  it { expect(delete: "/regions").to be_unroutable }

  it { expect(get:    "/regions/new").to       be_unroutable }
  it { expect(get:    "/regions/edit").to      be_unroutable }
  it { expect(get:    "/regions/remove").to    be_unroutable }
  it { expect(get:    "/regions/undiscard").to be_unroutable }
  it { expect(patch:  "/regions/undiscard").to be_unroutable }

  it { expect(get:    "/regions/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to route_to("regions#show", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(post:   "/regions/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to be_unroutable }
  it { expect(patch:  "/regions/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to route_to("regions#update", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(delete: "/regions/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to be_unroutable }

  it { expect(get:    "/regions/9c6c00c4-0784-4ef8-8978-b1e0246882a7/edit").to      route_to("regions#edit", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(get:    "/regions/9c6c00c4-0784-4ef8-8978-b1e0246882a7/remove").to    be_unroutable }
  it { expect(get:    "/regions/9c6c00c4-0784-4ef8-8978-b1e0246882a7/undiscard").to be_unroutable }
  it { expect(patch:  "/regions/9c6c00c4-0784-4ef8-8978-b1e0246882a7/undiscard").to be_unroutable }
end
