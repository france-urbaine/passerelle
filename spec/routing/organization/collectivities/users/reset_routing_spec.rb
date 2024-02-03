# frozen_string_literal: true

require "rails_helper"

RSpec.describe Organization::Collectivities::Users::ResetsController do
  let(:collectivity_id) { SecureRandom.uuid }
  let(:user_id)         { SecureRandom.uuid }
  let(:id)              { SecureRandom.uuid }

  it { expect(get:    "/organisation/collectivites/#{collectivity_id}/utilisateurs/#{user_id}/reset").to be_unroutable }
  it { expect(post:   "/organisation/collectivites/#{collectivity_id}/utilisateurs/#{user_id}/reset").to route_to("organization/collectivities/users/resets#create", collectivity_id:, user_id:) }
  it { expect(patch:  "/organisation/collectivites/#{collectivity_id}/utilisateurs/#{user_id}/reset").to be_unroutable }
  it { expect(delete: "/organisation/collectivites/#{collectivity_id}/utilisateurs/#{user_id}/reset").to be_unroutable }

  it { expect(get:    "/organisation/collectivites/#{collectivity_id}/utilisateurs/#{user_id}/reset/new").to       route_to("organization/collectivities/users/resets#new", collectivity_id:, user_id:) }
  it { expect(get:    "/organisation/collectivites/#{collectivity_id}/utilisateurs/#{user_id}/reset/edit").to      be_unroutable }
  it { expect(get:    "/organisation/collectivites/#{collectivity_id}/utilisateurs/#{user_id}/reset/remove").to    be_unroutable }
  it { expect(get:    "/organisation/collectivites/#{collectivity_id}/utilisateurs/#{user_id}/reset/undiscard").to be_unroutable }
  it { expect(patch:  "/organisation/collectivites/#{collectivity_id}/utilisateurs/#{user_id}/reset/undiscard").to be_unroutable }

  it { expect(get:    "/organisation/collectivites/#{collectivity_id}/utilisateurs/#{user_id}/reset/#{id}").to be_unroutable }
  it { expect(post:   "/organisation/collectivites/#{collectivity_id}/utilisateurs/#{user_id}/reset/#{id}").to be_unroutable }
  it { expect(patch:  "/organisation/collectivites/#{collectivity_id}/utilisateurs/#{user_id}/reset/#{id}").to be_unroutable }
  it { expect(delete: "/organisation/collectivites/#{collectivity_id}/utilisateurs/#{user_id}/reset/#{id}").to be_unroutable }

  it { expect(get:    "/organisation/collectivites/#{collectivity_id}/utilisateurs/#{user_id}/reset/#{id}/edit").to      be_unroutable }
  it { expect(get:    "/organisation/collectivites/#{collectivity_id}/utilisateurs/#{user_id}/reset/#{id}/remove").to    be_unroutable }
  it { expect(get:    "/organisation/collectivites/#{collectivity_id}/utilisateurs/#{user_id}/reset/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "/organisation/collectivites/#{collectivity_id}/utilisateurs/#{user_id}/reset/#{id}/undiscard").to be_unroutable }
end
