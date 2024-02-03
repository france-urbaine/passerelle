# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::UsersController do
  let(:id) { SecureRandom.uuid }

  it { expect(get:    "/admin/utilisateurs").to route_to("admin/users#index") }
  it { expect(post:   "/admin/utilisateurs").to route_to("admin/users#create") }
  it { expect(patch:  "/admin/utilisateurs").to be_unroutable }
  it { expect(delete: "/admin/utilisateurs").to route_to("admin/users#destroy_all") }

  it { expect(get:    "/admin/utilisateurs/new").to       route_to("admin/users#new") }
  it { expect(get:    "/admin/utilisateurs/edit").to      be_unroutable }
  it { expect(get:    "/admin/utilisateurs/remove").to    route_to("admin/users#remove_all") }
  it { expect(get:    "/admin/utilisateurs/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/utilisateurs/undiscard").to route_to("admin/users#undiscard_all") }

  it { expect(get:    "/admin/utilisateurs/#{id}").to route_to("admin/users#show", id:) }
  it { expect(post:   "/admin/utilisateurs/#{id}").to be_unroutable }
  it { expect(patch:  "/admin/utilisateurs/#{id}").to route_to("admin/users#update", id:) }
  it { expect(delete: "/admin/utilisateurs/#{id}").to route_to("admin/users#destroy", id:) }

  it { expect(get:    "/admin/utilisateurs/#{id}/edit").to      route_to("admin/users#edit", id:) }
  it { expect(get:    "/admin/utilisateurs/#{id}/remove").to    route_to("admin/users#remove", id:) }
  it { expect(get:    "/admin/utilisateurs/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/utilisateurs/#{id}/undiscard").to route_to("admin/users#undiscard", id:) }
end
