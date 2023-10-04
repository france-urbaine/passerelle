# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::TransmissionsController do
  it { expect(get:    "/api/collectivites/9c6c00c4-0784-4ef8-8978-b1e0246882a7/transmissions").to be_unroutable }
  it { expect(patch:  "/api/collectivites/9c6c00c4-0784-4ef8-8978-b1e0246882a7/transmissions").to be_unroutable }
  it { expect(delete: "/api/collectivites/9c6c00c4-0784-4ef8-8978-b1e0246882a7/transmissions").to be_unroutable }
  it { expect(post:   "/api/collectivites/9c6c00c4-0784-4ef8-8978-b1e0246882a7/transmissions").to route_to("api/transmissions#create", collectivity_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }

  it { expect(get:    "/api/transmissions/9c6c00c4-0784-4ef8-8978-b1e0246882a7/complete").to be_unroutable }
  it { expect(post:   "/api/transmissions/9c6c00c4-0784-4ef8-8978-b1e0246882a7/complete").to be_unroutable }
  it { expect(delete: "/api/transmissions/9c6c00c4-0784-4ef8-8978-b1e0246882a7/complete").to be_unroutable }
  it { expect(put:    "/api/transmissions/9c6c00c4-0784-4ef8-8978-b1e0246882a7/complete").to route_to("api/transmissions#complete", transmission_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
end
