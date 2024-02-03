# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::CollectivitiesController do
  let(:id) { SecureRandom.uuid }

  it { expect(get:    "/admin/collectivites").to route_to("admin/collectivities#index") }
  it { expect(post:   "/admin/collectivites").to route_to("admin/collectivities#create") }
  it { expect(patch:  "/admin/collectivites").to be_unroutable }
  it { expect(delete: "/admin/collectivites").to route_to("admin/collectivities#destroy_all") }

  it { expect(get:    "/admin/collectivites/new").to       route_to("admin/collectivities#new") }
  it { expect(get:    "/admin/collectivites/edit").to      be_unroutable }
  it { expect(get:    "/admin/collectivites/remove").to    route_to("admin/collectivities#remove_all") }
  it { expect(get:    "/admin/collectivites/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/collectivites/undiscard").to route_to("admin/collectivities#undiscard_all") }

  it { expect(get:    "/admin/collectivites/#{id}").to route_to("admin/collectivities#show", id:) }
  it { expect(post:   "/admin/collectivites/#{id}").to be_unroutable }
  it { expect(patch:  "/admin/collectivites/#{id}").to route_to("admin/collectivities#update", id:) }
  it { expect(delete: "/admin/collectivites/#{id}").to route_to("admin/collectivities#destroy", id:) }

  it { expect(get:    "/admin/collectivites/#{id}/edit").to      route_to("admin/collectivities#edit", id:) }
  it { expect(get:    "/admin/collectivites/#{id}/remove").to    route_to("admin/collectivities#remove", id:) }
  it { expect(get:    "/admin/collectivites/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/collectivites/#{id}/undiscard").to route_to("admin/collectivities#undiscard", id:) }
end
