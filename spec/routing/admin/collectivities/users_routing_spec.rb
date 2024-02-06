# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::Collectivities::UsersController do
  let(:collectivity_id) { SecureRandom.uuid }
  let(:id)              { SecureRandom.uuid }

  it { expect(get:    "/admin/collectivites/#{collectivity_id}/utilisateurs").to route_to("admin/collectivities/users#index", collectivity_id:) }
  it { expect(post:   "/admin/collectivites/#{collectivity_id}/utilisateurs").to route_to("admin/collectivities/users#create", collectivity_id:) }
  it { expect(patch:  "/admin/collectivites/#{collectivity_id}/utilisateurs").to be_unroutable }
  it { expect(delete: "/admin/collectivites/#{collectivity_id}/utilisateurs").to route_to("admin/collectivities/users#destroy_all", collectivity_id:) }

  it { expect(get:    "/admin/collectivites/#{collectivity_id}/utilisateurs/new").to       route_to("admin/collectivities/users#new", collectivity_id:) }
  it { expect(get:    "/admin/collectivites/#{collectivity_id}/utilisateurs/edit").to      be_unroutable }
  it { expect(get:    "/admin/collectivites/#{collectivity_id}/utilisateurs/remove").to    route_to("admin/collectivities/users#remove_all", collectivity_id:) }
  it { expect(get:    "/admin/collectivites/#{collectivity_id}/utilisateurs/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/collectivites/#{collectivity_id}/utilisateurs/undiscard").to route_to("admin/collectivities/users#undiscard_all", collectivity_id:) }

  it { expect(get:    "/admin/collectivites/#{collectivity_id}/utilisateurs/#{id}").to be_unroutable }
  it { expect(post:   "/admin/collectivites/#{collectivity_id}/utilisateurs/#{id}").to be_unroutable }
  it { expect(patch:  "/admin/collectivites/#{collectivity_id}/utilisateurs/#{id}").to be_unroutable }
  it { expect(delete: "/admin/collectivites/#{collectivity_id}/utilisateurs/#{id}").to be_unroutable }

  it { expect(get:    "/admin/collectivites/#{collectivity_id}/utilisateurs/#{id}/edit").to      be_unroutable }
  it { expect(get:    "/admin/collectivites/#{collectivity_id}/utilisateurs/#{id}/remove").to    be_unroutable }
  it { expect(get:    "/admin/collectivites/#{collectivity_id}/utilisateurs/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/collectivites/#{collectivity_id}/utilisateurs/#{id}/undiscard").to be_unroutable }
end
