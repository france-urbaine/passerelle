# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::PublishersController do
  let(:id) { SecureRandom.uuid }

  it { expect(get:    "/admin/editeurs").to route_to("admin/publishers#index") }
  it { expect(post:   "/admin/editeurs").to route_to("admin/publishers#create") }
  it { expect(patch:  "/admin/editeurs").to be_unroutable }
  it { expect(delete: "/admin/editeurs").to route_to("admin/publishers#destroy_all") }

  it { expect(get:    "/admin/editeurs/new").to       route_to("admin/publishers#new") }
  it { expect(get:    "/admin/editeurs/edit").to      be_unroutable }
  it { expect(get:    "/admin/editeurs/remove").to    route_to("admin/publishers#remove_all") }
  it { expect(get:    "/admin/editeurs/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/editeurs/undiscard").to route_to("admin/publishers#undiscard_all") }

  it { expect(get:    "/admin/editeurs/#{id}").to route_to("admin/publishers#show", id:) }
  it { expect(post:   "/admin/editeurs/#{id}").to be_unroutable }
  it { expect(patch:  "/admin/editeurs/#{id}").to route_to("admin/publishers#update", id:) }
  it { expect(delete: "/admin/editeurs/#{id}").to route_to("admin/publishers#destroy", id:) }

  it { expect(get:    "/admin/editeurs/#{id}/edit").to      route_to("admin/publishers#edit", id:) }
  it { expect(get:    "/admin/editeurs/#{id}/remove").to    route_to("admin/publishers#remove", id:) }
  it { expect(get:    "/admin/editeurs/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/editeurs/#{id}/undiscard").to route_to("admin/publishers#undiscard", id:) }
end
