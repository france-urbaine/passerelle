# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::DDFIPsController do
  let(:id) { SecureRandom.uuid }

  it { expect(get:    "/admin/ddfips").to route_to("admin/ddfips#index") }
  it { expect(post:   "/admin/ddfips").to route_to("admin/ddfips#create") }
  it { expect(patch:  "/admin/ddfips").to be_unroutable }
  it { expect(delete: "/admin/ddfips").to route_to("admin/ddfips#destroy_all") }

  it { expect(get:    "/admin/ddfips/new").to       route_to("admin/ddfips#new") }
  it { expect(get:    "/admin/ddfips/edit").to      be_unroutable }
  it { expect(get:    "/admin/ddfips/remove").to    route_to("admin/ddfips#remove_all") }
  it { expect(get:    "/admin/ddfips/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/ddfips/undiscard").to route_to("admin/ddfips#undiscard_all") }

  it { expect(get:    "/admin/ddfips/#{id}").to route_to("admin/ddfips#show", id:) }
  it { expect(post:   "/admin/ddfips/#{id}").to be_unroutable }
  it { expect(patch:  "/admin/ddfips/#{id}").to route_to("admin/ddfips#update", id:) }
  it { expect(delete: "/admin/ddfips/#{id}").to route_to("admin/ddfips#destroy", id:) }

  it { expect(get:    "/admin/ddfips/#{id}/edit").to      route_to("admin/ddfips#edit", id:) }
  it { expect(get:    "/admin/ddfips/#{id}/remove").to    route_to("admin/ddfips#remove", id:) }
  it { expect(get:    "/admin/ddfips/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/ddfips/#{id}/undiscard").to route_to("admin/ddfips#undiscard", id:) }
end
