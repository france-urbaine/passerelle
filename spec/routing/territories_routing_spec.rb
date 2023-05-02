# frozen_string_literal: true

require "rails_helper"

RSpec.describe TerritoriesController do
  it { expect(get:    "/territoires").to route_to("territories#index") }
  it { expect(post:   "/territoires").to be_unroutable }
  it { expect(patch:  "/territoires").to route_to("territories#update") }
  it { expect(delete: "/territoires").to be_unroutable }

  it { expect(get:    "/territoires/new").to       be_unroutable }
  it { expect(get:    "/territoires/edit").to      route_to("territories#edit") }
  it { expect(get:    "/territoires/remove").to    be_unroutable }
  it { expect(get:    "/territoires/undiscard").to be_unroutable }
  it { expect(patch:  "/territoires/undiscard").to be_unroutable }

  it { expect(get:    "/territoires/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to be_unroutable }
  it { expect(post:   "/territoires/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to be_unroutable }
  it { expect(patch:  "/territoires/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to be_unroutable }
  it { expect(delete: "/territoires/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to be_unroutable }
end
