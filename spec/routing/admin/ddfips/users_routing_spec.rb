# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::DDFIPs::UsersController do
  let(:ddfip_id) { SecureRandom.uuid }
  let(:id)       { SecureRandom.uuid }

  it { expect(get:    "/admin/ddfips/#{ddfip_id}/utilisateurs").to route_to("admin/ddfips/users#index", ddfip_id:) }
  it { expect(post:   "/admin/ddfips/#{ddfip_id}/utilisateurs").to route_to("admin/ddfips/users#create", ddfip_id:) }
  it { expect(patch:  "/admin/ddfips/#{ddfip_id}/utilisateurs").to be_unroutable }
  it { expect(delete: "/admin/ddfips/#{ddfip_id}/utilisateurs").to route_to("admin/ddfips/users#destroy_all", ddfip_id:) }

  it { expect(get:    "/admin/ddfips/#{ddfip_id}/utilisateurs/new").to       route_to("admin/ddfips/users#new", ddfip_id:) }
  it { expect(get:    "/admin/ddfips/#{ddfip_id}/utilisateurs/edit").to      be_unroutable }
  it { expect(get:    "/admin/ddfips/#{ddfip_id}/utilisateurs/remove").to    route_to("admin/ddfips/users#remove_all", ddfip_id:) }
  it { expect(get:    "/admin/ddfips/#{ddfip_id}/utilisateurs/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/ddfips/#{ddfip_id}/utilisateurs/undiscard").to route_to("admin/ddfips/users#undiscard_all", ddfip_id:) }

  it { expect(get:    "/admin/ddfips/#{ddfip_id}/utilisateurs/#{id}").to be_unroutable }
  it { expect(post:   "/admin/ddfips/#{ddfip_id}/utilisateurs/#{id}").to be_unroutable }
  it { expect(patch:  "/admin/ddfips/#{ddfip_id}/utilisateurs/#{id}").to be_unroutable }
  it { expect(delete: "/admin/ddfips/#{ddfip_id}/utilisateurs/#{id}").to be_unroutable }

  it { expect(get:    "/admin/ddfips/#{ddfip_id}/utilisateurs/#{id}/edit").to      be_unroutable }
  it { expect(get:    "/admin/ddfips/#{ddfip_id}/utilisateurs/#{id}/remove").to    be_unroutable }
  it { expect(get:    "/admin/ddfips/#{ddfip_id}/utilisateurs/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/ddfips/#{ddfip_id}/utilisateurs/#{id}/undiscard").to be_unroutable }
end
