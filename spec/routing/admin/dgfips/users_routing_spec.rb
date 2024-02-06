# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::DGFIPs::UsersController do
  let(:id) { SecureRandom.uuid }

  it { expect(get:    "/admin/dgfip/utilisateurs").to route_to("admin/dgfips/users#index") }
  it { expect(post:   "/admin/dgfip/utilisateurs").to route_to("admin/dgfips/users#create") }
  it { expect(patch:  "/admin/dgfip/utilisateurs").to be_unroutable }
  it { expect(delete: "/admin/dgfip/utilisateurs").to route_to("admin/dgfips/users#destroy_all") }

  it { expect(get:    "/admin/dgfip/utilisateurs/new").to       route_to("admin/dgfips/users#new") }
  it { expect(get:    "/admin/dgfip/utilisateurs/edit").to      be_unroutable }
  it { expect(get:    "/admin/dgfip/utilisateurs/remove").to    route_to("admin/dgfips/users#remove_all") }
  it { expect(get:    "/admin/dgfip/utilisateurs/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/dgfip/utilisateurs/undiscard").to route_to("admin/dgfips/users#undiscard_all") }

  it { expect(get:    "/admin/dgfip/utilisateurs/#{id}").to be_unroutable }
  it { expect(post:   "/admin/dgfip/utilisateurs/#{id}").to be_unroutable }
  it { expect(patch:  "/admin/dgfip/utilisateurs/#{id}").to be_unroutable }
  it { expect(delete: "/admin/dgfip/utilisateurs/#{id}").to be_unroutable }

  it { expect(get:    "/admin/dgfip/utilisateurs/#{id}/edit").to      be_unroutable }
  it { expect(get:    "/admin/dgfip/utilisateurs/#{id}/remove").to    be_unroutable }
  it { expect(get:    "/admin/dgfip/utilisateurs/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/dgfip/utilisateurs/#{id}/undiscard").to be_unroutable }
end
