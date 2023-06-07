# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReportsController do
  it { expect(get:    "/signalements").to route_to("reports#index") }
  it { expect(post:   "/signalements").to route_to("reports#create") }
  it { expect(patch:  "/signalements").to be_unroutable }
  it { expect(delete: "/signalements").to be_unroutable }

  it { expect(get:    "/signalements/new").to       route_to("reports#new") }
  it { expect(get:    "/signalements/edit").to      be_unroutable }
  it { expect(get:    "/signalements/remove").to    be_unroutable }
  it { expect(get:    "/signalements/undiscard").to be_unroutable }
  it { expect(patch:  "/signalements/undiscard").to be_unroutable }

  it { expect(get:    "/signalements/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to route_to("reports#show", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(post:   "/signalements/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to be_unroutable }
  it { expect(patch:  "/signalements/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to route_to("reports#update", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(delete: "/signalements/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to be_unroutable }
end
