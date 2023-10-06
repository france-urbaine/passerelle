# frozen_string_literal: true

require "rails_helper"

RSpec.describe API::ReportsController do
  it { expect(get:    "/api/transmissions/9c6c00c4-0784-4ef8-8978-b1e0246882a7/signalements").to be_unroutable }
  it { expect(patch:  "/api/transmissions/9c6c00c4-0784-4ef8-8978-b1e0246882a7/signalements").to be_unroutable }
  it { expect(delete: "/api/transmissions/9c6c00c4-0784-4ef8-8978-b1e0246882a7/signalements").to be_unroutable }
  it { expect(post:   "/api/transmissions/9c6c00c4-0784-4ef8-8978-b1e0246882a7/signalements").to route_to("api/reports#create", transmission_id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }

  it { expect(get:    "/api/transmissions/9c6c00c4-0784-4ef8-8978-b1e0246882a7/signalements/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to be_unroutable }
  it { expect(patch:  "/api/transmissions/9c6c00c4-0784-4ef8-8978-b1e0246882a7/signalements/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to be_unroutable }
  it { expect(post:   "/api/transmissions/9c6c00c4-0784-4ef8-8978-b1e0246882a7/signalements/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to be_unroutable }
  it { expect(delete: "/api/transmissions/9c6c00c4-0784-4ef8-8978-b1e0246882a7/signalements/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to be_unroutable }
end
