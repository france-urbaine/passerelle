# frozen_string_literal: true

require "rails_helper"

RSpec.describe CollectivitiesController do
  it { expect(get:    "/collectivites").to route_to("collectivities#index") }
  it { expect(post:   "/collectivites").to route_to("collectivities#create") }
  it { expect(patch:  "/collectivites").to be_unroutable }
  it { expect(delete: "/collectivites").to route_to("collectivities#destroy_all") }

  it { expect(get:    "/collectivites/new").to       route_to("collectivities#new") }
  it { expect(get:    "/collectivites/edit").to      be_unroutable }
  it { expect(get:    "/collectivites/remove").to    route_to("collectivities#remove_all") }
  it { expect(get:    "/collectivites/undiscard").to be_unroutable }
  it { expect(patch:  "/collectivites/undiscard").to route_to("collectivities#undiscard_all") }

  it { expect(get:    "/collectivites/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to route_to("collectivities#show", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(post:   "/collectivites/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to be_unroutable }
  it { expect(patch:  "/collectivites/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to route_to("collectivities#update", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(delete: "/collectivites/9c6c00c4-0784-4ef8-8978-b1e0246882a7").to route_to("collectivities#destroy", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }

  it { expect(get:    "/collectivites/9c6c00c4-0784-4ef8-8978-b1e0246882a7/edit").to      route_to("collectivities#edit", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(get:    "/collectivites/9c6c00c4-0784-4ef8-8978-b1e0246882a7/remove").to    route_to("collectivities#remove", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
  it { expect(get:    "/collectivites/9c6c00c4-0784-4ef8-8978-b1e0246882a7/undiscard").to be_unroutable }
  it { expect(patch:  "/collectivites/9c6c00c4-0784-4ef8-8978-b1e0246882a7/undiscard").to route_to("collectivities#undiscard", id: "9c6c00c4-0784-4ef8-8978-b1e0246882a7") }
end
