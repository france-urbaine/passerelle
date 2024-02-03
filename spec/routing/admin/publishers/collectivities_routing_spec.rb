# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::Publishers::CollectivitiesController do
  let(:publisher_id) { SecureRandom.uuid }
  let(:id)           { SecureRandom.uuid }

  it { expect(get:    "/admin/editeurs/#{publisher_id}/collectivites").to route_to("admin/publishers/collectivities#index", publisher_id:) }
  it { expect(post:   "/admin/editeurs/#{publisher_id}/collectivites").to route_to("admin/publishers/collectivities#create", publisher_id:) }
  it { expect(patch:  "/admin/editeurs/#{publisher_id}/collectivites").to be_unroutable }
  it { expect(delete: "/admin/editeurs/#{publisher_id}/collectivites").to route_to("admin/publishers/collectivities#destroy_all", publisher_id:) }

  it { expect(get:    "/admin/editeurs/#{publisher_id}/collectivites/new").to       route_to("admin/publishers/collectivities#new", publisher_id:) }
  it { expect(get:    "/admin/editeurs/#{publisher_id}/collectivites/edit").to      be_unroutable }
  it { expect(get:    "/admin/editeurs/#{publisher_id}/collectivites/remove").to    route_to("admin/publishers/collectivities#remove_all", publisher_id:) }
  it { expect(get:    "/admin/editeurs/#{publisher_id}/collectivites/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/editeurs/#{publisher_id}/collectivites/undiscard").to route_to("admin/publishers/collectivities#undiscard_all", publisher_id:) }

  it { expect(get:    "/admin/editeurs/#{publisher_id}/collectivites/#{id}").to be_unroutable }
  it { expect(post:   "/admin/editeurs/#{publisher_id}/collectivites/#{id}").to be_unroutable }
  it { expect(patch:  "/admin/editeurs/#{publisher_id}/collectivites/#{id}").to be_unroutable }
  it { expect(delete: "/admin/editeurs/#{publisher_id}/collectivites/#{id}").to be_unroutable }

  it { expect(get:    "/admin/editeurs/#{publisher_id}/collectivites/#{id}/edit").to      be_unroutable }
  it { expect(get:    "/admin/editeurs/#{publisher_id}/collectivites/#{id}/remove").to    be_unroutable }
  it { expect(get:    "/admin/editeurs/#{publisher_id}/collectivites/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/editeurs/#{publisher_id}/collectivites/#{id}/undiscard").to be_unroutable }
end
