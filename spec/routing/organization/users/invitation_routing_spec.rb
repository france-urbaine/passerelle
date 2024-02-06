# frozen_string_literal: true

require "rails_helper"

RSpec.describe Organization::Users::InvitationsController do
  let(:user_id) { SecureRandom.uuid }
  let(:id)      { SecureRandom.uuid }

  it { expect(get:    "/organisation/utilisateurs/#{user_id}/invitation").to be_unroutable }
  it { expect(post:   "/organisation/utilisateurs/#{user_id}/invitation").to route_to("organization/users/invitations#create", user_id:) }
  it { expect(patch:  "/organisation/utilisateurs/#{user_id}/invitation").to be_unroutable }
  it { expect(delete: "/organisation/utilisateurs/#{user_id}/invitation").to be_unroutable }

  it { expect(get:    "/organisation/utilisateurs/#{user_id}/invitation/new").to       route_to("organization/users/invitations#new", user_id:) }
  it { expect(get:    "/organisation/utilisateurs/#{user_id}/invitation/edit").to      be_unroutable }
  it { expect(get:    "/organisation/utilisateurs/#{user_id}/invitation/remove").to    be_unroutable }
  it { expect(get:    "/organisation/utilisateurs/#{user_id}/invitation/undiscard").to be_unroutable }
  it { expect(patch:  "/organisation/utilisateurs/#{user_id}/invitation/undiscard").to be_unroutable }

  it { expect(get:    "/organisation/utilisateurs/#{user_id}/invitation/#{id}").to be_unroutable }
  it { expect(post:   "/organisation/utilisateurs/#{user_id}/invitation/#{id}").to be_unroutable }
  it { expect(patch:  "/organisation/utilisateurs/#{user_id}/invitation/#{id}").to be_unroutable }
  it { expect(delete: "/organisation/utilisateurs/#{user_id}/invitation/#{id}").to be_unroutable }

  it { expect(get:    "/organisation/utilisateurs/#{user_id}/invitation/#{id}/edit").to      be_unroutable }
  it { expect(get:    "/organisation/utilisateurs/#{user_id}/invitation/#{id}/remove").to    be_unroutable }
  it { expect(get:    "/organisation/utilisateurs/#{user_id}/invitation/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "/organisation/utilisateurs/#{user_id}/invitation/#{id}/undiscard").to be_unroutable }
end
