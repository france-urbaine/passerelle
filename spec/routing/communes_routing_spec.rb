# frozen_string_literal: true

require "rails_helper"

RSpec.describe CommunesController do
  it { expect(get:    "/communes").to     route_to("communes#index") }
  it { expect(post:   "/communes").not_to be_routable }
  it { expect(patch:  "/communes").not_to be_routable }
  it { expect(delete: "/communes").not_to be_routable }

  it { expect(get:    "/communes/new").to       route_to("communes#show", id: "new") }
  it { expect(get:    "/communes/remove").to    route_to("communes#show", id: "remove") }
  it { expect(get:    "/communes/undiscard").to route_to("communes#show", id: "undiscard") }
  it { expect(patch:  "/communes/undiscard").to route_to("communes#update", id: "undiscard") }

  it { expect(get:    "/communes/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to     route_to("communes#show", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(post:   "/communes/9c6c00c4-0784-4ef8-8978-b1e0246882a7").not_to be_routable }
  it { expect(patch:  "/communes/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to     route_to("communes#update", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(delete: "/communes/9c6c00c4-0784-4ef8-8978-b1e0246882a7").not_to be_routable }

  it { expect(get:    "/communes/9c6c00c4-0784-4ef8-8978-b1e0246882a7/edit").to          route_to("communes#edit", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(get:    "/communes/9c6c00c4-0784-4ef8-8978-b1e0246882a7/remove").not_to    be_routable }
  it { expect(get:    "/communes/9c6c00c4-0784-4ef8-8978-b1e0246882a7/undiscard").not_to be_routable }
  it { expect(patch:  "/communes/9c6c00c4-0784-4ef8-8978-b1e0246882a7/undiscard").not_to be_routable }
end
