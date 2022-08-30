# frozen_string_literal: true

require "rails_helper"

RSpec.describe CollectivitiesController, type: :routing do
  it { expect(get:    "/collectivites").to     route_to("collectivities#index") }
  it { expect(post:   "/collectivites").to     route_to("collectivities#create") }
  it { expect(patch:  "/collectivites").not_to be_routable }
  it { expect(delete: "/collectivites").not_to be_routable }

  it { expect(get:    "/collectivites/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to     route_to("collectivities#show", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(post:   "/collectivites/9c6c00c4-0784-4ef8-8978-b1e0246882a7").not_to be_routable }
  it { expect(patch:  "/collectivites/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to     route_to("collectivities#update", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(delete: "/collectivites/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to     route_to("collectivities#destroy", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }

  it { expect(get:    "/collectivites/new").to                                       route_to("collectivities#new") }
  it { expect(get:    "/collectivites/9c6c00c4-0784-4ef8-8978-b1e0246882a7/edit").to route_to("collectivities#edit", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
end
