# frozen_string_literal: true

require "rails_helper"

RSpec.describe RegionsController, type: :routing do
  it { expect(get:    "/regions").to     route_to("regions#index") }
  it { expect(post:   "/regions").not_to be_routable }
  it { expect(patch:  "/regions").not_to be_routable }
  it { expect(delete: "/regions").not_to be_routable }

  it { expect(get:    "/regions/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to     route_to("regions#show", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(post:   "/regions/9c6c00c4-0784-4ef8-8978-b1e0246882a7").not_to be_routable }
  it { expect(patch:  "/regions/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to     route_to("regions#update", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(delete: "/regions/9c6c00c4-0784-4ef8-8978-b1e0246882a7").not_to be_routable }

  it { expect(get:    "/regions/new").to                                       route_to("regions#show", id: "new") }
  it { expect(get:    "/regions/9c6c00c4-0784-4ef8-8978-b1e0246882a7/edit").to route_to("regions#edit", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
end
