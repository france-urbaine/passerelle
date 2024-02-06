# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::Offices::UsersController do
  let(:office_id) { SecureRandom.uuid }
  let(:id)        { SecureRandom.uuid }

  it { expect(get:    "/admin/guichets/#{office_id}/utilisateurs").to route_to("admin/offices/users#index", office_id:) }
  it { expect(post:   "/admin/guichets/#{office_id}/utilisateurs").to route_to("admin/offices/users#create", office_id:) }
  it { expect(patch:  "/admin/guichets/#{office_id}/utilisateurs").to route_to("admin/offices/users#update_all", office_id:) }
  it { expect(delete: "/admin/guichets/#{office_id}/utilisateurs").to route_to("admin/offices/users#destroy_all", office_id:) }

  it { expect(get:    "/admin/guichets/#{office_id}/utilisateurs/new").to       route_to("admin/offices/users#new", office_id:) }
  it { expect(get:    "/admin/guichets/#{office_id}/utilisateurs/edit").to      route_to("admin/offices/users#edit_all", office_id:) }
  it { expect(get:    "/admin/guichets/#{office_id}/utilisateurs/remove").to    route_to("admin/offices/users#remove_all", office_id:) }
  it { expect(get:    "/admin/guichets/#{office_id}/utilisateurs/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/guichets/#{office_id}/utilisateurs/undiscard").to be_unroutable }

  it { expect(get:    "/admin/guichets/#{office_id}/utilisateurs/#{id}").to be_unroutable }
  it { expect(post:   "/admin/guichets/#{office_id}/utilisateurs/#{id}").to be_unroutable }
  it { expect(patch:  "/admin/guichets/#{office_id}/utilisateurs/#{id}").to be_unroutable }
  it { expect(delete: "/admin/guichets/#{office_id}/utilisateurs/#{id}").to route_to("admin/offices/users#destroy", office_id:, id:) }

  it { expect(get:    "/admin/guichets/#{office_id}/utilisateurs/#{id}/edit").to      be_unroutable }
  it { expect(get:    "/admin/guichets/#{office_id}/utilisateurs/#{id}/remove").to    route_to("admin/offices/users#remove", office_id:, id:) }
  it { expect(get:    "/admin/guichets/#{office_id}/utilisateurs/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/guichets/#{office_id}/utilisateurs/#{id}/undiscard").to be_unroutable }
end
