# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::CollectivitiesController do
  it { expect(get:    "/admin/collectivites").to route_to("admin/collectivities#index") }
  it { expect(post:   "/admin/collectivites").to route_to("admin/collectivities#create") }
  it { expect(patch:  "/admin/collectivites").to be_unroutable }
  it { expect(delete: "/admin/collectivites").to route_to("admin/collectivities#destroy_all") }

  it { expect(get:    "/admin/collectivites/new").to       route_to("admin/collectivities#new") }
  it { expect(get:    "/admin/collectivites/edit").to      be_unroutable }
  it { expect(get:    "/admin/collectivites/remove").to    route_to("admin/collectivities#remove_all") }
  it { expect(get:    "/admin/collectivites/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/collectivites/undiscard").to route_to("admin/collectivities#undiscard_all") }

  it { expect(get:    "/admin/collectivites/9c6c00c4").to route_to("admin/collectivities#show", id: "9c6c00c4") }
  it { expect(post:   "/admin/collectivites/9c6c00c4").to be_unroutable }
  it { expect(patch:  "/admin/collectivites/9c6c00c4").to route_to("admin/collectivities#update", id: "9c6c00c4") }
  it { expect(delete: "/admin/collectivites/9c6c00c4").to route_to("admin/collectivities#destroy", id: "9c6c00c4") }

  it { expect(get:    "/admin/collectivites/9c6c00c4/edit").to      route_to("admin/collectivities#edit", id: "9c6c00c4") }
  it { expect(get:    "/admin/collectivites/9c6c00c4/remove").to    route_to("admin/collectivities#remove", id: "9c6c00c4") }
  it { expect(get:    "/admin/collectivites/9c6c00c4/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/collectivites/9c6c00c4/undiscard").to route_to("admin/collectivities#undiscard", id: "9c6c00c4") }
end
