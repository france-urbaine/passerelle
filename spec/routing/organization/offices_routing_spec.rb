# frozen_string_literal: true

require "rails_helper"

RSpec.describe Organization::OfficesController do
  it { expect(get:    "/organisation/guichets").to route_to("organization/offices#index") }
  it { expect(post:   "/organisation/guichets").to route_to("organization/offices#create") }
  it { expect(patch:  "/organisation/guichets").to be_unroutable }
  it { expect(delete: "/organisation/guichets").to route_to("organization/offices#destroy_all") }

  it { expect(get:    "/organisation/guichets/new").to       route_to("organization/offices#new") }
  it { expect(get:    "/organisation/guichets/edit").to      be_unroutable }
  it { expect(get:    "/organisation/guichets/remove").to    route_to("organization/offices#remove_all") }
  it { expect(get:    "/organisation/guichets/undiscard").to be_unroutable }
  it { expect(patch:  "/organisation/guichets/undiscard").to route_to("organization/offices#undiscard_all") }

  it { expect(get:    "/organisation/guichets/9c6c00c4").to route_to("organization/offices#show", id: "9c6c00c4") }
  it { expect(post:   "/organisation/guichets/9c6c00c4").to be_unroutable }
  it { expect(patch:  "/organisation/guichets/9c6c00c4").to route_to("organization/offices#update", id: "9c6c00c4") }
  it { expect(delete: "/organisation/guichets/9c6c00c4").to route_to("organization/offices#destroy", id: "9c6c00c4") }

  it { expect(get:    "/organisation/guichets/9c6c00c4/edit").to      route_to("organization/offices#edit", id: "9c6c00c4") }
  it { expect(get:    "/organisation/guichets/9c6c00c4/remove").to    route_to("organization/offices#remove", id: "9c6c00c4") }
  it { expect(get:    "/organisation/guichets/9c6c00c4/undiscard").to be_unroutable }
  it { expect(patch:  "/organisation/guichets/9c6c00c4/undiscard").to route_to("organization/offices#undiscard", id: "9c6c00c4") }
end
