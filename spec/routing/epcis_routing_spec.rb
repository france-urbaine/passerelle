# frozen_string_literal: true

require "rails_helper"

RSpec.describe EpcisController do
  it { expect(get:    "/epcis").to     route_to("epcis#index") }
  it { expect(post:   "/epcis").not_to be_routable }
  it { expect(patch:  "/epcis").not_to be_routable }
  it { expect(delete: "/epcis").not_to be_routable }

  it { expect(get:    "/epcis/new").to       route_to("epcis#show", id: "new") }
  it { expect(get:    "/epcis/remove").to    route_to("epcis#show", id: "remove") }
  it { expect(get:    "/epcis/undiscard").to route_to("epcis#show", id: "undiscard") }
  it { expect(patch:  "/epcis/undiscard").to route_to("epcis#update", id: "undiscard") }

  it { expect(get:    "/epcis/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to     route_to("epcis#show", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(post:   "/epcis/9c6c00c4-0784-4ef8-8978-b1e0246882a7").not_to be_routable }
  it { expect(patch:  "/epcis/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to     route_to("epcis#update", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(delete: "/epcis/9c6c00c4-0784-4ef8-8978-b1e0246882a7").not_to be_routable }

  it { expect(get:    "/epcis/9c6c00c4-0784-4ef8-8978-b1e0246882a7/edit").to          route_to("epcis#edit", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(get:    "/epcis/9c6c00c4-0784-4ef8-8978-b1e0246882a7/remove").not_to    be_routable }
  it { expect(get:    "/epcis/9c6c00c4-0784-4ef8-8978-b1e0246882a7/undiscard").not_to be_routable }
  it { expect(patch:  "/epcis/9c6c00c4-0784-4ef8-8978-b1e0246882a7/undiscard").not_to be_routable }
end
