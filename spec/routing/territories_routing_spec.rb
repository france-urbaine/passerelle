# frozen_string_literal: true

require "rails_helper"

RSpec.describe TerritoriesController, type: :routing do
  it { expect(get:    "/territoires").to     route_to("territories#index") }
  it { expect(post:   "/territoires").not_to be_routable }
  it { expect(patch:  "/territoires").to     route_to("territories#update") }
  it { expect(delete: "/territoires").not_to be_routable }

  it { expect(get:    "/territoires/new").not_to be_routable }
  it { expect(get:    "/territoires/edit").to    route_to("territories#edit") }

  it { expect(get:    "/territoires/9c6c00c4-0784-4ef8-8978-b1e0246882a7").not_to be_routable }
  it { expect(post:   "/territoires/9c6c00c4-0784-4ef8-8978-b1e0246882a7").not_to be_routable }
  it { expect(patch:  "/territoires/9c6c00c4-0784-4ef8-8978-b1e0246882a7").not_to be_routable }
  it { expect(delete: "/territoires/9c6c00c4-0784-4ef8-8978-b1e0246882a7").not_to be_routable }
end
