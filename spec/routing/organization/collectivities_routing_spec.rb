# frozen_string_literal: true

require "rails_helper"

RSpec.describe Organization::CollectivitiesController do
  it { expect(get:    "/organisation/collectivites").to route_to("organization/collectivities#index") }
  it { expect(post:   "/organisation/collectivites").to route_to("organization/collectivities#create") }
  it { expect(patch:  "/organisation/collectivites").to be_unroutable }
  it { expect(delete: "/organisation/collectivites").to route_to("organization/collectivities#destroy_all") }

  it { expect(get:    "/organisation/collectivites/new").to       route_to("organization/collectivities#new") }
  it { expect(get:    "/organisation/collectivites/edit").to      be_unroutable }
  it { expect(get:    "/organisation/collectivites/remove").to    route_to("organization/collectivities#remove_all") }
  it { expect(get:    "/organisation/collectivites/undiscard").to be_unroutable }
  it { expect(patch:  "/organisation/collectivites/undiscard").to route_to("organization/collectivities#undiscard_all") }

  it { expect(get:    "/organisation/collectivites/9c6c00c4").to route_to("organization/collectivities#show", id: "9c6c00c4") }
  it { expect(post:   "/organisation/collectivites/9c6c00c4").to be_unroutable }
  it { expect(patch:  "/organisation/collectivites/9c6c00c4").to route_to("organization/collectivities#update", id: "9c6c00c4") }
  it { expect(delete: "/organisation/collectivites/9c6c00c4").to route_to("organization/collectivities#destroy", id: "9c6c00c4") }

  it { expect(get:    "/organisation/collectivites/9c6c00c4/edit").to      route_to("organization/collectivities#edit", id: "9c6c00c4") }
  it { expect(get:    "/organisation/collectivites/9c6c00c4/remove").to    route_to("organization/collectivities#remove", id: "9c6c00c4") }
  it { expect(get:    "/organisation/collectivites/9c6c00c4/undiscard").to be_unroutable }
  it { expect(patch:  "/organisation/collectivites/9c6c00c4/undiscard").to route_to("organization/collectivities#undiscard", id: "9c6c00c4") }
end
