# frozen_string_literal: true

require "rails_helper"

RSpec.describe Organization::Collectivities::UsersController do
  let(:collectivity_id) { SecureRandom.uuid }
  let(:id)              { SecureRandom.uuid }

  it { expect(get:    "/organisation/collectivites/#{collectivity_id}/utilisateurs").to route_to("organization/collectivities/users#index", collectivity_id:) }
  it { expect(post:   "/organisation/collectivites/#{collectivity_id}/utilisateurs").to route_to("organization/collectivities/users#create", collectivity_id:) }
  it { expect(patch:  "/organisation/collectivites/#{collectivity_id}/utilisateurs").to be_unroutable }
  it { expect(delete: "/organisation/collectivites/#{collectivity_id}/utilisateurs").to route_to("organization/collectivities/users#destroy_all", collectivity_id:) }

  it { expect(get:    "/organisation/collectivites/#{collectivity_id}/utilisateurs/new").to       route_to("organization/collectivities/users#new", collectivity_id:) }
  it { expect(get:    "/organisation/collectivites/#{collectivity_id}/utilisateurs/edit").to      be_unroutable }
  it { expect(get:    "/organisation/collectivites/#{collectivity_id}/utilisateurs/remove").to    route_to("organization/collectivities/users#remove_all", collectivity_id:) }
  it { expect(get:    "/organisation/collectivites/#{collectivity_id}/utilisateurs/undiscard").to be_unroutable }
  it { expect(patch:  "/organisation/collectivites/#{collectivity_id}/utilisateurs/undiscard").to route_to("organization/collectivities/users#undiscard_all", collectivity_id:) }

  it { expect(get:    "/organisation/collectivites/#{collectivity_id}/utilisateurs/#{id}").to route_to("organization/collectivities/users#show", collectivity_id:, id:) }
  it { expect(post:   "/organisation/collectivites/#{collectivity_id}/utilisateurs/#{id}").to be_unroutable }
  it { expect(patch:  "/organisation/collectivites/#{collectivity_id}/utilisateurs/#{id}").to route_to("organization/collectivities/users#update", collectivity_id:, id:) }
  it { expect(delete: "/organisation/collectivites/#{collectivity_id}/utilisateurs/#{id}").to route_to("organization/collectivities/users#destroy", collectivity_id:, id:) }

  it { expect(get:    "/organisation/collectivites/#{collectivity_id}/utilisateurs/#{id}/edit").to      route_to("organization/collectivities/users#edit", collectivity_id:, id:) }
  it { expect(get:    "/organisation/collectivites/#{collectivity_id}/utilisateurs/#{id}/remove").to    route_to("organization/collectivities/users#remove", collectivity_id:, id:) }
  it { expect(get:    "/organisation/collectivites/#{collectivity_id}/utilisateurs/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "/organisation/collectivites/#{collectivity_id}/utilisateurs/#{id}/undiscard").to route_to("organization/collectivities/users#undiscard", collectivity_id:, id:) }
end
