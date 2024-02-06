# frozen_string_literal: true

require "rails_helper"

RSpec.describe Organization::OfficesController do
  let(:id) { SecureRandom.uuid }

  it { expect(get:    "/organisation/guichets").to route_to("organization/offices#index") }
  it { expect(post:   "/organisation/guichets").to route_to("organization/offices#create") }
  it { expect(patch:  "/organisation/guichets").to be_unroutable }
  it { expect(delete: "/organisation/guichets").to route_to("organization/offices#destroy_all") }

  it { expect(get:    "/organisation/guichets/new").to       route_to("organization/offices#new") }
  it { expect(get:    "/organisation/guichets/edit").to      be_unroutable }
  it { expect(get:    "/organisation/guichets/remove").to    route_to("organization/offices#remove_all") }
  it { expect(get:    "/organisation/guichets/undiscard").to be_unroutable }
  it { expect(patch:  "/organisation/guichets/undiscard").to route_to("organization/offices#undiscard_all") }

  it { expect(get:    "/organisation/guichets/#{id}").to route_to("organization/offices#show", id:) }
  it { expect(post:   "/organisation/guichets/#{id}").to be_unroutable }
  it { expect(patch:  "/organisation/guichets/#{id}").to route_to("organization/offices#update", id:) }
  it { expect(delete: "/organisation/guichets/#{id}").to route_to("organization/offices#destroy", id:) }

  it { expect(get:    "/organisation/guichets/#{id}/edit").to      route_to("organization/offices#edit", id:) }
  it { expect(get:    "/organisation/guichets/#{id}/remove").to    route_to("organization/offices#remove", id:) }
  it { expect(get:    "/organisation/guichets/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "/organisation/guichets/#{id}/undiscard").to route_to("organization/offices#undiscard", id:) }
end
