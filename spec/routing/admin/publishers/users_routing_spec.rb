# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::Publishers::UsersController do
  let(:publisher_id) { SecureRandom.uuid }
  let(:id)           { SecureRandom.uuid }

  it { expect(get:    "/admin/editeurs/#{publisher_id}/utilisateurs").to route_to("admin/publishers/users#index", publisher_id:) }
  it { expect(post:   "/admin/editeurs/#{publisher_id}/utilisateurs").to route_to("admin/publishers/users#create", publisher_id:) }
  it { expect(patch:  "/admin/editeurs/#{publisher_id}/utilisateurs").to be_unroutable }
  it { expect(delete: "/admin/editeurs/#{publisher_id}/utilisateurs").to route_to("admin/publishers/users#destroy_all", publisher_id:) }

  it { expect(get:    "/admin/editeurs/#{publisher_id}/utilisateurs/new").to       route_to("admin/publishers/users#new", publisher_id:) }
  it { expect(get:    "/admin/editeurs/#{publisher_id}/utilisateurs/edit").to      be_unroutable }
  it { expect(get:    "/admin/editeurs/#{publisher_id}/utilisateurs/remove").to    route_to("admin/publishers/users#remove_all", publisher_id:) }
  it { expect(get:    "/admin/editeurs/#{publisher_id}/utilisateurs/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/editeurs/#{publisher_id}/utilisateurs/undiscard").to route_to("admin/publishers/users#undiscard_all", publisher_id:) }

  it { expect(get:    "/admin/editeurs/#{publisher_id}/utilisateurs/#{id}").to be_unroutable }
  it { expect(post:   "/admin/editeurs/#{publisher_id}/utilisateurs/#{id}").to be_unroutable }
  it { expect(patch:  "/admin/editeurs/#{publisher_id}/utilisateurs/#{id}").to be_unroutable }
  it { expect(delete: "/admin/editeurs/#{publisher_id}/utilisateurs/#{id}").to be_unroutable }

  it { expect(get:    "/admin/editeurs/#{publisher_id}/utilisateurs/#{id}/edit").to      be_unroutable }
  it { expect(get:    "/admin/editeurs/#{publisher_id}/utilisateurs/#{id}/remove").to    be_unroutable }
  it { expect(get:    "/admin/editeurs/#{publisher_id}/utilisateurs/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/editeurs/#{publisher_id}/utilisateurs/#{id}/undiscard").to be_unroutable }
end
