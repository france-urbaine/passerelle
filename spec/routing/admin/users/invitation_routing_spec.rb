# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::Users::InvitationsController do
  let(:user_id) { SecureRandom.uuid }
  let(:id)      { SecureRandom.uuid }

  it { expect(get:    "/admin/utilisateurs/#{user_id}/invitation").to be_unroutable }
  it { expect(post:   "/admin/utilisateurs/#{user_id}/invitation").to route_to("admin/users/invitations#create", user_id:) }
  it { expect(patch:  "/admin/utilisateurs/#{user_id}/invitation").to be_unroutable }
  it { expect(delete: "/admin/utilisateurs/#{user_id}/invitation").to be_unroutable }

  it { expect(get:    "/admin/utilisateurs/#{user_id}/invitation/new").to       route_to("admin/users/invitations#new", user_id:) }
  it { expect(get:    "/admin/utilisateurs/#{user_id}/invitation/edit").to      be_unroutable }
  it { expect(get:    "/admin/utilisateurs/#{user_id}/invitation/remove").to    be_unroutable }
  it { expect(get:    "/admin/utilisateurs/#{user_id}/invitation/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/utilisateurs/#{user_id}/invitation/undiscard").to be_unroutable }

  it { expect(get:    "/admin/utilisateurs/#{user_id}/invitation/#{id}").to be_unroutable }
  it { expect(post:   "/admin/utilisateurs/#{user_id}/invitation/#{id}").to be_unroutable }
  it { expect(patch:  "/admin/utilisateurs/#{user_id}/invitation/#{id}").to be_unroutable }
  it { expect(delete: "/admin/utilisateurs/#{user_id}/invitation/#{id}").to be_unroutable }

  it { expect(get:    "/admin/utilisateurs/#{user_id}/invitation/#{id}/edit").to      be_unroutable }
  it { expect(get:    "/admin/utilisateurs/#{user_id}/invitation/#{id}/remove").to    be_unroutable }
  it { expect(get:    "/admin/utilisateurs/#{user_id}/invitation/#{id}/undiscard").to be_unroutable }
  it { expect(patch:  "/admin/utilisateurs/#{user_id}/invitation/#{id}/undiscard").to be_unroutable }
end
