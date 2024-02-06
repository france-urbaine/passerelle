# frozen_string_literal: true

require "rails_helper"

RSpec.describe Organization::Collectivities::Users::InvitationsController do
  let(:collectivity_id) { SecureRandom.uuid }
  let(:user_id)         { SecureRandom.uuid }
  let(:id)              { SecureRandom.uuid }

  it { expect(get:    "/organisation/collectivites/#{collectivity_id}/utilisateurs/#{user_id}/invitation").to be_unroutable }
  it { expect(post:   "/organisation/collectivites/#{collectivity_id}/utilisateurs/#{user_id}/invitation").to route_to("organization/collectivities/users/invitations#create", collectivity_id:, user_id:) }
  it { expect(patch:  "/organisation/collectivites/#{collectivity_id}/utilisateurs/#{user_id}/invitation").to be_unroutable }
  it { expect(delete: "/organisation/collectivites/#{collectivity_id}/utilisateurs/#{user_id}/invitation").to be_unroutable }

  it { expect(get:    "/organisation/collectivites/#{collectivity_id}/utilisateurs/#{user_id}/invitation/new").to       route_to("organization/collectivities/users/invitations#new", collectivity_id:, user_id:) }
  it { expect(get:    "/organisation/collectivites/#{collectivity_id}/utilisateurs/#{user_id}/invitation/edit").to      be_unroutable }
  it { expect(get:    "/organisation/collectivites/#{collectivity_id}/utilisateurs/#{user_id}/invitation/remove").to    be_unroutable }
  it { expect(get:    "/organisation/collectivites/#{collectivity_id}/utilisateurs/#{user_id}/invitation/undiscard").to be_unroutable }
  it { expect(patch:  "/organisation/collectivites/#{collectivity_id}/utilisateurs/#{user_id}/invitation/undiscard").to be_unroutable }

  it { expect(get:    "/organisation/collectivites/#{collectivity_id}/utilisateurs/#{user_id}/invitation/#{id}").to be_unroutable }
  it { expect(post:   "/organisation/collectivites/#{collectivity_id}/utilisateurs/#{user_id}/invitation/#{id}").to be_unroutable }
  it { expect(patch:  "/organisation/collectivites/#{collectivity_id}/utilisateurs/#{user_id}/invitation/#{id}").to be_unroutable }
  it { expect(delete: "/organisation/collectivites/#{collectivity_id}/utilisateurs/#{user_id}/invitation/#{id}").to be_unroutable }

  it { expect(get:    "/organisation/collectivites/#{collectivity_id}/utilisateurs/#{user_id}/invitation/#{id}/edit").to      be_unroutable }
  it { expect(get:    "/organisation/collectivites/#{collectivity_id}/utilisateurs/#{user_id}/invitation/#{id}/remove").to    be_unroutable }
  it { expect(get:    "/organisation/collectivites/#{collectivity_id}/utilisateurs/#{user_id}/invitation/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "/organisation/collectivites/#{collectivity_id}/utilisateurs/#{user_id}/invitation/#{id}/undiscard").to be_unroutable }
end
