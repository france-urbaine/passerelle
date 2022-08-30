# frozen_string_literal: true

require "rails_helper"

RSpec.describe TerritoriesUpdatesController, type: :routing do
  it { expect(get:    "/territoires").to     route_to("territories_updates#show") }
  it { expect(post:   "/territoires").to     route_to("territories_updates#create") }
  it { expect(patch:  "/territoires").not_to be_routable }
  it { expect(delete: "/territoires").not_to be_routable }

  it { expect(get:    "/territoires/9c6c00c4-0784-4ef8-8978-b1e0246882a7").not_to be_routable }
  it { expect(post:   "/territoires/9c6c00c4-0784-4ef8-8978-b1e0246882a7").not_to be_routable }
  it { expect(patch:  "/territoires/9c6c00c4-0784-4ef8-8978-b1e0246882a7").not_to be_routable }
  it { expect(delete: "/territoires/9c6c00c4-0784-4ef8-8978-b1e0246882a7").not_to be_routable }
  it { expect(get:    "/territoires/new").not_to be_routable }
end
