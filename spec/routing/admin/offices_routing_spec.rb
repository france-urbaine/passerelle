# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::OfficesController do
  let(:id) { SecureRandom.uuid }

  it { expect(get:    "/admin/guichets").to route_to("admin/offices#index") }
  it { expect(post:   "/admin/guichets").to route_to("admin/offices#create") }
  it { expect(patch:  "/admin/guichets").to be_unroutable }
  it { expect(delete: "/admin/guichets").to route_to("admin/offices#destroy_all") }

  it { expect(get:    "/admin/guichets/new").to       route_to("admin/offices#new") }
  it { expect(get:    "/admin/guichets/edit").to      be_unroutable }
  it { expect(get:    "/admin/guichets/remove").to    route_to("admin/offices#remove_all") }
  it { expect(get:    "/admin/guichets/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/guichets/undiscard").to route_to("admin/offices#undiscard_all") }

  it { expect(get:    "/admin/guichets/#{id}").to route_to("admin/offices#show", id:) }
  it { expect(post:   "/admin/guichets/#{id}").to be_unroutable }
  it { expect(patch:  "/admin/guichets/#{id}").to route_to("admin/offices#update", id:) }
  it { expect(delete: "/admin/guichets/#{id}").to route_to("admin/offices#destroy", id:) }

  it { expect(get:    "/admin/guichets/#{id}/edit").to      route_to("admin/offices#edit", id:) }
  it { expect(get:    "/admin/guichets/#{id}/remove").to    route_to("admin/offices#remove", id:) }
  it { expect(get:    "/admin/guichets/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/guichets/#{id}/undiscard").to route_to("admin/offices#undiscard", id:) }
end
