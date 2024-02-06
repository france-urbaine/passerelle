# frozen_string_literal: true

require "rails_helper"

RSpec.describe Organization::CollectivitiesController do
  let(:id) { SecureRandom.uuid }

  it { expect(get:    "/organisation/collectivites").to route_to("organization/collectivities#index") }
  it { expect(post:   "/organisation/collectivites").to route_to("organization/collectivities#create") }
  it { expect(patch:  "/organisation/collectivites").to be_unroutable }
  it { expect(delete: "/organisation/collectivites").to route_to("organization/collectivities#destroy_all") }

  it { expect(get:    "/organisation/collectivites/new").to       route_to("organization/collectivities#new") }
  it { expect(get:    "/organisation/collectivites/edit").to      be_unroutable }
  it { expect(get:    "/organisation/collectivites/remove").to    route_to("organization/collectivities#remove_all") }
  it { expect(get:    "/organisation/collectivites/undiscard").to be_unroutable }
  it { expect(patch:  "/organisation/collectivites/undiscard").to route_to("organization/collectivities#undiscard_all") }

  it { expect(get:    "/organisation/collectivites/#{id}").to route_to("organization/collectivities#show", id:) }
  it { expect(post:   "/organisation/collectivites/#{id}").to be_unroutable }
  it { expect(patch:  "/organisation/collectivites/#{id}").to route_to("organization/collectivities#update", id:) }
  it { expect(delete: "/organisation/collectivites/#{id}").to route_to("organization/collectivities#destroy", id:) }

  it { expect(get:    "/organisation/collectivites/#{id}/edit").to      route_to("organization/collectivities#edit", id:) }
  it { expect(get:    "/organisation/collectivites/#{id}/remove").to    route_to("organization/collectivities#remove", id:) }
  it { expect(get:    "/organisation/collectivites/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "/organisation/collectivites/#{id}/undiscard").to route_to("organization/collectivities#undiscard", id:) }
end
