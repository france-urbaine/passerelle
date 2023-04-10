# frozen_string_literal: true

require "rails_helper"

RSpec.describe TerritoriesController do
  it { expect(get:    "/organisations").to     route_to("organizations#index") }
  it { expect(post:   "/organisations").not_to be_routable }
  it { expect(patch:  "/organisations").not_to be_routable }
  it { expect(delete: "/organisations").not_to be_routable }

  it { expect(get:    "/organisations/new").not_to       be_routable }
  it { expect(get:    "/organisations/remove").not_to    be_routable }
  it { expect(get:    "/organisations/undiscard").not_to be_routable }
  it { expect(patch:  "/organisations/undiscard").not_to be_routable }

  it { expect(get:    "/organisations/9c6c00c4-0784-4ef8-8978-b1e0246882a7").not_to be_routable }
  it { expect(post:   "/organisations/9c6c00c4-0784-4ef8-8978-b1e0246882a7").not_to be_routable }
  it { expect(patch:  "/organisations/9c6c00c4-0784-4ef8-8978-b1e0246882a7").not_to be_routable }
  it { expect(delete: "/organisations/9c6c00c4-0784-4ef8-8978-b1e0246882a7").not_to be_routable }
end
