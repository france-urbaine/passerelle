# frozen_string_literal: true

require "rails_helper"

RSpec.describe DepartementsController do
  it { expect(get:    "/departements").to     route_to("departements#index") }
  it { expect(post:   "/departements").not_to be_routable }
  it { expect(patch:  "/departements").not_to be_routable }
  it { expect(delete: "/departements").not_to be_routable }

  it { expect(get:    "/departements/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to     route_to("departements#show", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(post:   "/departements/9c6c00c4-0784-4ef8-8978-b1e0246882a7").not_to be_routable }
  it { expect(patch:  "/departements/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to     route_to("departements#update", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(delete: "/departements/9c6c00c4-0784-4ef8-8978-b1e0246882a7").not_to be_routable }

  it { expect(get:    "/departements/new").to                                       route_to("departements#show", id: "new") }
  it { expect(get:    "/departements/9c6c00c4-0784-4ef8-8978-b1e0246882a7/edit").to route_to("departements#edit", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
end
